//
//  DocumentsService.swift
//  Healthside
//

import ComposableArchitecture
import Foundation

public nonisolated struct DocumentsService: IDocumentsService {
    private let network: any INetwork

    public init(network: any INetwork) {
        self.network = network
    }

    public func list() async throws -> [DocumentDTO] {
        do {
            return try await network.request(DocumentsEndpoint.list)
        } catch {
            throw APIErrorMapper.map(error)
        }
    }

    public func document(id: String) async throws -> DocumentDTO {
        do {
            return try await network.request(DocumentsEndpoint.get(id: id))
        } catch {
            throw APIErrorMapper.map(error)
        }
    }
}

// MARK: - Dependency

private enum DocumentsServiceKey: DependencyKey {
    static var liveValue: any IDocumentsService {
        @Dependency(\.network) var network
        return DocumentsService(network: network)
    }
}

public extension DependencyValues {
    nonisolated var documentsService: any IDocumentsService {
        get { self[DocumentsServiceKey.self] }
        set { self[DocumentsServiceKey.self] = newValue }
    }
}
