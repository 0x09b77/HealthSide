//
//  RootView.swift
//  Healthside
//

import ComposableArchitecture
import SwiftUI

struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        AppView(store: store.scope(state: \.app, action: \.app))
            .overlay {
                if showsCover {
                    AppLockView(store: store.scope(state: \.lock, action: \.lock))
                        .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.2), value: showsCover)
            .task { store.send(.lock(.task)) }
            .onChange(of: scenePhase, initial: false) { _, phase in
                store.send(.phaseChanged(AppPhase(phase)))
            }
    }

    /// Крышка: залочено — или сцена неактивна (прячем контент из снапшота).
    private var showsCover: Bool {
        store.lock.isLocked || (scenePhase != .active && store.isAuthenticatedArea)
    }
}

private extension AppPhase {
    init(_ phase: ScenePhase) {
        switch phase {
        case .active: self = .active
        case .inactive: self = .inactive
        case .background: self = .background
        @unknown default: self = .inactive
        }
    }
}
