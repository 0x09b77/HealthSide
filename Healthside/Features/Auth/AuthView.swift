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
                Text(isLogin ? "Welcome back" : "Create your account")
                    .font(.system(size: 26, weight: .heavy))
                    .tracking(-0.5)
                    .foregroundStyle(HSColor.ink)

                Text(isLogin ? "Log in to your Healthside account." : "Free. Takes a minute.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(HSColor.inkSecondary)
                    .padding(.top, 6)

                VStack(spacing: 16) {
                    HSTextField(
                        "Email",
                        placeholder: "you@email.com",
                        text: $store.email,
                        errorMessage: store.emailError,
                        keyboardType: .emailAddress,
                        textContentType: .username,
                        submitLabel: .next
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                    HSTextField(
                        "Password",
                        placeholder: "Password",
                        text: $store.password,
                        isSecure: true,
                        errorMessage: store.passwordError,
                        textContentType: isLogin ? .password : .newPassword,
                        submitLabel: .go
                    )
                }
                .padding(.top, 28)

                if isLogin {
                    Button("Forgot password?") {
                        store.send(.forgotPasswordTapped)
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(HSColor.coral)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 12)
                }

                HSButton(
                    isLogin ? "Log in" : "Create account",
                    isLoading: store.isSubmitting
                ) {
                    store.send(.submitTapped)
                }
                .disabled(!store.canSubmit)
                .padding(.top, 24)

                if !isLogin {
                    Text("By continuing you agree to our Terms and Privacy.")
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
            Text(isLogin ? "New here?" : "Have an account?")
                .foregroundStyle(HSColor.inkSecondary)
            Button(isLogin ? "Create account" : "Log in") {
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
