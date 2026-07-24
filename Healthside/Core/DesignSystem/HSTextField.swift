//
//  HSTextField.swift
//  Healthside
//
//  Поле ввода дизайн-системы. Состояния (default / focused / filled / error /
//  disabled) выводятся из фокуса, ошибки и isEnabled. Секретный режим — с
//  переключателем видимости.
//

import SwiftUI
import UIKit

public struct HSTextField: View {
    private let title: String?
    private let placeholder: String
    @Binding private var text: String
    private let isSecure: Bool
    private let errorMessage: String?
    private let keyboardType: UIKeyboardType
    private let textContentType: UITextContentType?
    private let submitLabel: SubmitLabel

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false
    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ title: String? = nil,
        placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        errorMessage: String? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        submitLabel: SubmitLabel = .return
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.errorMessage = errorMessage
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.submitLabel = submitLabel
    }

    private var isError: Bool { errorMessage != nil }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(labelColor)
            }

            HStack(spacing: 10) {
                inputField
                if isSecure {
                    revealButton
                }
            }
            .padding(.horizontal, 15)
            .frame(height: 52)
            .background(RoundedRectangle(cornerRadius: 14).fill(fillColor))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
            .overlay {
                if showRing {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(HSColor.coralRing, lineWidth: 4)
                        .padding(-2)
                }
            }
            .animation(.easeOut(duration: 0.15), value: isFocused)
            .animation(.easeOut(duration: 0.15), value: isError)

            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(HSColor.danger)
                    .labelStyle(.titleAndIcon)
            }
        }
    }

    @ViewBuilder
    private var inputField: some View {
        let prompt = Text(placeholder).foregroundColor(HSColor.placeholder)
        Group {
            if isSecure, !isRevealed {
                SecureField("", text: $text, prompt: prompt)
            } else {
                TextField("", text: $text, prompt: prompt)
            }
        }
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(textColor)
        .focused($isFocused)
        .tint(HSColor.coral)
        .keyboardType(keyboardType)
        .textContentType(textContentType)
        .submitLabel(submitLabel)
    }

    private var revealButton: some View {
        Button {
            isRevealed.toggle()
        } label: {
            Image(systemName: isRevealed ? "eye.slash" : "eye")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(HSColor.inkSecondary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Стиль по состоянию

    private var labelColor: Color {
        if isError { return HSColor.danger }
        return isEnabled ? HSColor.inkSecondary : HSColor.labelDisabled
    }

    private var fillColor: Color {
        if !isEnabled { return HSColor.fieldFillDisabled }
        if isFocused { return HSColor.surface }
        if isError { return HSColor.dangerFill }
        return HSColor.fieldFill
    }

    private var borderColor: Color {
        if !isEnabled { return .clear }
        if isFocused { return HSColor.coral }
        if isError { return HSColor.dangerBorder }
        return .clear
    }

    private var textColor: Color {
        isEnabled ? HSColor.ink : HSColor.textDisabled
    }

    private var showRing: Bool { isFocused && isEnabled }
}

#Preview {
    @Previewable @State var empty = ""
    @Previewable @State var name = "Alex Rivera"
    @Previewable @State var email = "alex@email.com"
    @Previewable @State var password = "supersecret"

    return ScrollView {
        VStack(spacing: 20) {
            HSTextField("Default", placeholder: "Placeholder text", text: $empty)
            HSTextField("Filled", placeholder: "Name", text: $name)
            HSTextField(
                "Error",
                placeholder: "Email",
                text: $email,
                errorMessage: "Enter a valid email"
            )
            HSTextField("Password", placeholder: "Password", text: $password, isSecure: true)
            HSTextField("Disabled", placeholder: "Placeholder text", text: $empty)
                .disabled(true)
        }
        .padding(24)
    }
    .background(HSColor.background)
}
