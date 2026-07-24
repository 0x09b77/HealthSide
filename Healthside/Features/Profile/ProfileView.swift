//
//  ProfileView.swift
//  Healthside
//

import ComposableArchitecture
import SwiftUI

struct ProfileView: View {
    @Bindable var store: StoreOf<ProfileFeature>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    account
                    securitySection
                    privacySection
                    logoutButton
                }
                .padding(20)
            }
            .background(HSColor.background)
            .navigationTitle("Profile")
            .task { store.send(.task) }
        }
    }

    // MARK: - Аккаунт

    private var account: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(HSColor.coralSoft)
                .frame(width: 52, height: 52)
                .overlay(
                    Text(store.avatarInitial)
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(HSColor.coral)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(store.user?.email ?? "…")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(HSColor.ink)
                    .lineLimit(1)
                if let memberSince = store.memberSince {
                    Text("Member since \(memberSince)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(HSColor.inkSecondary)
                }
            }
            Spacer()
        }
    }

    // MARK: - Секции

    private var securitySection: some View {
        section("SECURITY") {
            if store.hasBiometry {
                toggleRow(
                    title: store.biometryKind.displayName,
                    isOn: $store.isBiometricLockEnabled.sending(\.biometricLockToggled)
                )
                divider
            }
            row(title: "Auto-lock", value: "After 1 min", isEnabled: false)
            divider
            row(title: "Change password", isEnabled: false)
        }
    }

    private var privacySection: some View {
        section("PRIVACY & DATA") {
            row(title: "Export my data", isEnabled: false)
            divider
            row(title: "Delete everything", isEnabled: false)
        }
    }

    private var logoutButton: some View {
        HSButton("Log out", style: .secondary, isLoading: store.isLoggingOut) {
            store.send(.logoutTapped)
        }
    }

    // MARK: - Строительные блоки

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .tracking(0.72)
                .foregroundStyle(HSColor.labelDisabled)

            VStack(spacing: 0) {
                content()
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(HSColor.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(HSColor.hairline, lineWidth: 1))
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HSColor.ink)
        }
        .tint(HSColor.coral)
        .padding(.horizontal, 16)
        .frame(height: 52)
    }

    /// Строка-переход. Неактивные — те, под которые в API ещё нет эндпоинта.
    private func row(title: String, value: String? = nil, isEnabled: Bool) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isEnabled ? HSColor.ink : HSColor.textDisabled)
            Spacer()
            if let value {
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HSColor.textDisabled)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(HSColor.labelDisabled)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }

    private var divider: some View {
        Rectangle()
            .fill(HSColor.hairline)
            .frame(height: 1)
            .padding(.leading, 16)
    }
}
