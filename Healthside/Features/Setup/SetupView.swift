//
//  SetupView.swift
//  Healthside
//

import ComposableArchitecture
import SwiftUI

struct SetupView: View {
    let store: StoreOf<SetupFeature>

    var body: some View {
        Group {
            switch store.step {
            case .consent: consentStep
            case .notifications: notificationsStep
            case .faceID: faceIDStep
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(HSColor.background)
        .animation(.easeInOut(duration: 0.2), value: store.step)
        .onAppear { store.send(.onAppear) }
    }

    // MARK: - Steps

    private var consentStep: some View {
        scaffold(
            icon: "lock.shield.fill",
            title: "Before we start",
            body: "To read your analyses, we process them securely with a trusted provider. Personal details are removed first. You can delete everything anytime."
        ) {
            Button {
                store.send(.consentToggled)
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: store.consentAccepted ? "checkmark.square.fill" : "square")
                        .font(.system(size: 22))
                        .foregroundStyle(store.consentAccepted ? HSColor.coral : HSColor.inkSecondary)
                    Text("I agree to secure cloud processing of my documents.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(HSColor.ink)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)

            HSButton("Agree and continue") {
                store.send(.agreeConsentTapped)
            }
            .disabled(!store.consentAccepted)
        }
    }

    private var notificationsStep: some View {
        scaffold(
            icon: "bell.badge.fill",
            title: "Stay in the loop",
            body: "Get a notification the moment your results are parsed and ready to view."
        ) {
            HSButton("Enable notifications", isLoading: store.isRequestingPermission) {
                store.send(.enableNotificationsTapped)
            }
            HSButton("Not now", style: .secondary) {
                store.send(.skipNotificationsTapped)
            }
        }
    }

    private var faceIDStep: some View {
        let name = store.biometry.displayName
        return scaffold(
            icon: store.biometry == .touchID ? "touchid" : "faceid",
            title: "Lock with \(name)",
            body: "Your health data stays private. We'll ask for \(name) each time you open the app."
        ) {
            HSButton("Enable \(name)", isLoading: store.isRequestingPermission) {
                store.send(.enableFaceIDTapped)
            }
            HSButton("Set up later", style: .secondary) {
                store.send(.skipFaceIDTapped)
            }
        }
    }

    // MARK: - Scaffold

    private func scaffold(
        icon: String,
        title: String,
        body: String,
        @ViewBuilder actions: () -> some View
    ) -> some View {
        VStack(spacing: 0) {
            Spacer()

            RoundedRectangle(cornerRadius: 30)
                .fill(HSColor.coralSoft)
                .frame(width: 116, height: 116)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 46, weight: .semibold))
                        .foregroundStyle(HSColor.coral)
                )

            Text(title)
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
                .foregroundStyle(HSColor.ink)
                .padding(.top, 26)

            Text(body)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HSColor.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 4)

            Spacer()

            VStack(spacing: 12, content: actions)
        }
    }
}

#Preview {
    SetupView(
        store: Store(initialState: SetupFeature.State()) {
            SetupFeature()
        }
    )
}
