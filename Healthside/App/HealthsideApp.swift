//
//  HealthsideApp.swift
//  Healthside
//
//  Точка входа / composition root. Держит корневой Store с AppFeature.
//

import ComposableArchitecture
import SwiftUI

@main
struct HealthsideApp: App {
    static let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: HealthsideApp.store)
        }
    }
}
