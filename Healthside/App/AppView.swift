//
//  AppView.swift
//  Healthside
//
//  Корневая вью. Свитчит по состоянию сессии.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        Group {
            switch store.state {
            case .launching:
                ProgressView()

            case .welcome:
                if let store = store.scope(state: \.welcome, action: \.welcome) {
                    WelcomeView(store: store)
                }

            case .auth:
                if let store = store.scope(state: \.auth, action: \.auth) {
                    AuthView(store: store)
                }

            case .setup:
                if let store = store.scope(state: \.setup, action: \.setup) {
                    SetupView(store: store)
                }

            case .main:
                if let store = store.scope(state: \.main, action: \.main) {
                    MainView(store: store)
                }
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}
