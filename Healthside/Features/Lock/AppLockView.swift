//
//  AppLockView.swift
//  Healthside
//
//  Крышка поверх контента. Кнопки показываем только когда реально залочено —
//  при простом уходе в неактивное состояние это просто privacy-заглушка.
//

import ComposableArchitecture
import SwiftUI

struct AppLockView: View {
    let store: StoreOf<AppLockFeature>

    var body: some View {
        ZStack {
            HSColor.background.ignoresSafeArea()

            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(HSColor.coralSoft)
                    .frame(width: 108, height: 108)
                    .overlay(
                        Image(systemName: lockSymbol)
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(HSColor.coral)
                    )

                if store.isLocked {
                    Text(L10n.Lock.title)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(HSColor.ink)

                    Text(L10n.Lock.body(store.biometryKind.displayName))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(HSColor.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    if store.didFail {
                        Label(L10n.Lock.failed, systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(HSColor.danger)
                    }

                    VStack(spacing: 10) {
                        HSButton(
                            L10n.Lock.unlockButton(store.biometryKind.displayName),
                            isLoading: store.isAuthenticating
                        ) {
                            store.send(.unlockTapped)
                        }

                        Button(L10n.Shared.logOut) {
                            store.send(.logOutTapped)
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(HSColor.inkSecondary)
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 32)
                }
            }
        }
    }

    private var lockSymbol: String {
        switch store.biometryKind {
        case .faceID, .opticID: "faceid"
        case .touchID: "touchid"
        case .none: "lock.fill"
        }
    }
}
