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
            title: L10n.Setup.Consent.title,
            body: L10n.Setup.Consent.body
        ) {
            Button {
                store.send(.consentToggled)
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: store.consentAccepted ? "checkmark.square.fill" : "square")
                        .font(.system(size: 22))
                        .foregroundStyle(store.consentAccepted ? HSColor.coral : HSColor.inkSecondary)
                    Text(L10n.Setup.Consent.checkbox)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(HSColor.ink)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)

            HSButton(L10n.Setup.Consent.cta) {
                store.send(.agreeConsentTapped)
            }
            .disabled(!store.consentAccepted)
        }
    }

    private var notificationsStep: some View {
        scaffold(
            icon: "bell.badge.fill",
            title: L10n.Setup.Notifications.title,
            body: L10n.Setup.Notifications.body
        ) {
            HSButton(L10n.Setup.Notifications.enable, isLoading: store.isRequestingPermission) {
                store.send(.enableNotificationsTapped)
            }
            HSButton(L10n.Setup.Notifications.skip, style: .secondary) {
                store.send(.skipNotificationsTapped)
            }
        }
    }

    private var faceIDStep: some View {
        let name = store.biometry.displayName
        return scaffold(
            icon: store.biometry == .touchID ? "touchid" : "faceid",
            title: L10n.Setup.FaceId.title(name),
            body: L10n.Setup.FaceId.body(name)
        ) {
            HSButton(L10n.Setup.FaceId.enable(name), isLoading: store.isRequestingPermission) {
                store.send(.enableFaceIDTapped)
            }
            HSButton(L10n.Setup.FaceId.skip, style: .secondary) {
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
