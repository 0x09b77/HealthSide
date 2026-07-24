//
//  HSButton.swift
//  Healthside
//
//  Кнопка дизайн-системы. Primary (коралл) / secondary (бежевый филл).
//  height 52, radius 14, 15/600. Поддерживает лоадер и disabled.
//

import SwiftUI

public struct HSButton: View {
    public enum Style {
        case primary
        case secondary
    }

    private let title: String
    private let style: Style
    private let isLoading: Bool
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ title: String,
        style: Style = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Text(title).opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView().tint(foreground)
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(foreground)
            .background(RoundedRectangle(cornerRadius: 14).fill(background))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeOut(duration: 0.15), value: isLoading)
    }

    private var foreground: Color {
        switch style {
        case .primary: .white
        case .secondary: HSColor.ink
        }
    }

    private var background: Color {
        switch style {
        case .primary: HSColor.coral
        case .secondary: HSColor.fieldFill
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HSButton("Log in") {}
        HSButton("Create account", isLoading: true) {}
        HSButton("Secondary", style: .secondary) {}
        HSButton("Disabled") {}.disabled(true)
    }
    .padding(24)
    .background(HSColor.background)
}
