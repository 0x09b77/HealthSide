//
//  PublicKeyPinningDelegate.swift
//  Healthside
//
//  Public-key (SPKI) pinning. Пины — base64(SHA256(SubjectPublicKeyInfo)),
//  считаются стандартным способом:
//
//    openssl s_client -connect host:443 </dev/null 2>/dev/null \
//      | openssl x509 -pubkey -noout \
//      | openssl pkey -pubin -outform der \
//      | openssl dgst -sha256 -binary | base64
//
//  Хост без пинов проходит стандартную проверку доверия (не блокируется).
//  Пиньте минимум два ключа (текущий + бэкап), иначе ротация сертификата уронит доступ.
//

import CryptoKit
import Foundation

public nonisolated final class PublicKeyPinningDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {
    /// host → набор допустимых base64(SHA256(SPKI)).
    private let pinnedKeyHashes: [String: Set<String>]

    public init(pinnedKeyHashes: [String: Set<String>]) {
        self.pinnedKeyHashes = pinnedKeyHashes
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Хост без пинов — стандартная проверка.
        guard let pins = pinnedKeyHashes[challenge.protectionSpace.host], !pins.isEmpty else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // 1) Обычная валидация цепочки доверия.
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // 2) Совпадение хотя бы одного пина в цепочке.
        if Self.trustChain(serverTrust, matchesAnyOf: pins) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    // MARK: - SPKI hashing

    private static func trustChain(_ trust: SecTrust, matchesAnyOf pins: Set<String>) -> Bool {
        guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate] else {
            return false
        }
        for certificate in chain {
            if let hash = spkiSHA256(for: certificate), pins.contains(hash) {
                return true
            }
        }
        return false
    }

    private static func spkiSHA256(for certificate: SecCertificate) -> String? {
        guard let publicKey = SecCertificateCopyKey(certificate),
              let keyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data?,
              let header = asn1Header(for: publicKey) else {
            return nil
        }
        var data = Data(header)
        data.append(keyData)
        return Data(SHA256.hash(data: data)).base64EncodedString()
    }

    private static func asn1Header(for key: SecKey) -> [UInt8]? {
        guard let attributes = SecKeyCopyAttributes(key) as? [CFString: Any],
              let keyType = attributes[kSecAttrKeyType] as? String,
              let keySize = attributes[kSecAttrKeySizeInBits] as? Int else {
            return nil
        }
        if keyType == (kSecAttrKeyTypeRSA as String) {
            switch keySize {
            case 2048: return rsa2048Header
            case 4096: return rsa4096Header
            default: return nil
            }
        } else if keyType == (kSecAttrKeyTypeECSECPrimeRandom as String) {
            switch keySize {
            case 256: return ecSecp256r1Header
            case 384: return ecSecp384r1Header
            default: return nil
            }
        }
        return nil
    }

    // ASN.1 SPKI-заголовки по типу/размеру ключа (как в TrustKit).
    private static let rsa2048Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00,
    ]
    private static let rsa4096Header: [UInt8] = [
        0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00,
    ]
    private static let ecSecp256r1Header: [UInt8] = [
        0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
        0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
        0x42, 0x00,
    ]
    private static let ecSecp384r1Header: [UInt8] = [
        0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
        0x01, 0x06, 0x05, 0x2b, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00,
    ]
}

public extension URLSession {
    /// Сессия с public-key pinning. Хосты без пинов — обычная проверка доверия.
    nonisolated static func pinned(
        pinnedKeyHashes: [String: Set<String>],
        configuration: URLSessionConfiguration = .default
    ) -> URLSession {
        let delegate = PublicKeyPinningDelegate(pinnedKeyHashes: pinnedKeyHashes)
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}
