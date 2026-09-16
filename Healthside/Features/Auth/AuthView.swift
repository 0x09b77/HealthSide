//
//  AuthView.swift
//  Healthside
//

import ComposableArchitecture
import SwiftUI

struct AuthView: View {
    @Bindable var store: StoreOf<AuthFeature>

    private var isLogin: Bool { store.mode == .login }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(isLogin ? L10n.Auth.Title.login : L10n.Auth.Title.register)
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(-0.5)
                    .foregroundStyle(HSColor.ink)

                Text(isLogin ? L10n.Auth.Subtitle.login : L10n.Auth.Subtitle.register)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(HSColor.inkSecondary)
                    .padding(.top, 6)

                VStack(spacing: 16) {
                    HSTextField(
                        L10n.Auth.Email.label,
                        placeholder: L10n.Auth.Email.placeholder,
                        text: $store.email,
                        errorMessage: store.emailError,
                        keyboardType: .emailAddress,
                        textContentType: .username,
                        submitLabel: .next
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    HSTextField(
                        L10n.Auth.Password.label,
                        placeholder: L10n.Auth.Password.placeholder,
                        text: $store.password,
                        isSecure: true,
                        errorMessage: store.passwordError,
                        textContentType: isLogin ? .password : .newPassword,
                        submitLabel: .go
                    )
                }
                .padding(.top, 28)

                if isLogin {
                    Button(L10n.Auth.forgotPassword) {
                        store.send(.forgotPasswordTapped)
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(HSColor.coral)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 12)
                }

                HSButton(
                    isLogin ? L10n.Auth.Submit.login : L10n.Auth.Submit.register,
                    isLoading: store.isSubmitting
                ) {
                    store.send(.submitTapped)
                }
                .disabled(!store.canSubmit)
                .padding(.top, 24)

                if !isLogin {
                    Text(L10n.Auth.termsNotice)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(HSColor.inkSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)
                }

                footer
                    .padding(.top, 22)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
        }
        .background(HSColor.background)
        .scrollDismissesKeyboard(.interactively)
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Text(isLogin ? L10n.Auth.Footer.loginPrompt : L10n.Auth.Footer.registerPrompt)
                .foregroundStyle(HSColor.inkSecondary)
            Button(isLogin ? L10n.Auth.Footer.createAccount : L10n.Auth.Footer.logIn) {
                store.send(.modeToggled)
            }
            .foregroundStyle(HSColor.coral)
        }
        .font(.system(size: 14, weight: .semibold))
    }
}

#Preview {
    AuthView(
        store: Store(initialState: AuthFeature.State()) {
            AuthFeature()
        }
    )
}
