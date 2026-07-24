//
//  HSStatusBadge.swift
//  Healthside
//
//  Пилюля-статус (success / warning / danger / neutral) с иконкой.
//

import SwiftUI

public struct HSStatusBadge: View {
    public enum Kind {
        case success
        case warning
        case danger
        case neutral
    }

    private let kind: Kind
    private let text: String
    private let systemImage: String

    public init(_ text: String, systemImage: String, kind: Kind) {
        self.text = text
        self.systemImage = systemImage
        self.kind = kind
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(background))
    }

    private var foreground: Color {
        switch kind {
        case .success: HSColor.success
        case .warning: HSColor.warning
        case .danger: HSColor.danger
        case .neutral: HSColor.inkSecondary
        }
    }

    private var background: Color {
        switch kind {
        case .success: HSColor.successFill
        case .warning: HSColor.warningFill
        case .danger: HSColor.dangerFill
        case .neutral: HSColor.fieldFill
        }
    }
}
