//
//  DocumentRow.swift
//  Healthside
//
//  Строка документа для списков (Home, Records) + маппинг парс-статуса в бейдж.
//

import SwiftUI

public struct DocumentRow: View {
    private let document: DocumentDTO

    public init(_ document: DocumentDTO) {
        self.document = document
    }

    public var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(document.displayTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(HSColor.ink)
                Text(document.displaySubtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(HSColor.inkSecondary)
            }
            Spacer(minLength: 8)
            documentStatusBadge(document.status)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(HSColor.surface))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(HSColor.hairline, lineWidth: 1))
    }
}

public func documentStatusBadge(_ status: ParseStatus) -> HSStatusBadge {
    switch status {
    case .done:
        HSStatusBadge(L10n.Status.Document.done, systemImage: "checkmark", kind: .success)
    case .pending:
        HSStatusBadge(L10n.Status.Document.pending, systemImage: "clock", kind: .warning)
    case .processing:
        HSStatusBadge(L10n.Status.Document.processing, systemImage: "clock", kind: .warning)
    case .failed:
        HSStatusBadge(L10n.Status.Document.failed, systemImage: "exclamationmark.triangle", kind: .danger)
    }
}
