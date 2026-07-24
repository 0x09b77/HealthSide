//
//  LabResultsService.swift
//  Healthside
//

import ComposableArchitecture
import Foundation

public nonisolated struct LabResultsService: ILabResultsService {
    private let network: any INetwork

    public init(network: any INetwork) {
        self.network = network
    }

    public func upload(
        fileData: Data,
        fileName: String,
        mimeType: String,
        label: String?
    ) async throws -> UploadAcceptedDTO {
        try await mappingErrors {
            var form = MultipartFormData()
            form.addFile(name: "file", fileName: fileName, mimeType: mimeType, data: fileData)
            if let label {
                form.addField(name: "label", value: label)
            }
            let data = try await network.upload(LabResultsEndpoint.upload, multipart: form)
            return try JSONDecoder.healthside.decode(UploadAcceptedDTO.self, from: data)
        }
    }

    public func list() async throws -> [LabResultDTO] {
        try await mappingErrors {
            try await network.request(LabResultsEndpoint.list)
        }
    }

    public func download(id: String) async throws -> Data {
        try await mappingErrors {
            try await network.data(for: LabResultsEndpoint.download(id: id))
        }
    }

    public func delete(id: String) async throws {
        try await mappingErrors {
            try await network.send(LabResultsEndpoint.delete(id: id))
        }
    }

    private func mappingErrors<T>(_ work: () async throws -> T) async throws -> T {
        do {
            return try await work()
        } catch {
            throw APIErrorMapper.map(error)
        }
    }
}

// MARK: - Dependency

private enum LabResultsServiceKey: DependencyKey {
    static var liveValue: any ILabResultsService {
        @Dependency(\.network) var network
        return LabResultsService(network: network)
    }
}

public extension DependencyValues {
    nonisolated var labResultsService: any ILabResultsService {
        get { self[LabResultsServiceKey.self] }
        set { self[LabResultsServiceKey.self] = newValue }
    }
}
