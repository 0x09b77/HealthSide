//
//  MainView.swift
//  Healthside
//
//  Таб-бар: [ Home ] [ Records ] ( ＋ ) [ Insights ] [ Profile ].
//  «＋» — плавающая кнопка по центру, открывает модалку добавления.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    @Bindable var store: StoreOf<MainFeature>

    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            HomeView(store: store.scope(state: \.home, action: \.home))
                .tabItem { Label("Home", systemImage: "house") }
                .tag(MainFeature.Tab.home)

            RecordsView(store: store.scope(state: \.records, action: \.records))
                .tabItem { Label("Records", systemImage: "doc.text") }
                .tag(MainFeature.Tab.records)

            InsightsView(store: store.scope(state: \.insights, action: \.insights))
                .tabItem { Label("Insights", systemImage: "chart.xyaxis.line") }
                .tag(MainFeature.Tab.insights)

            ProfileView(store: store.scope(state: \.profile, action: \.profile))
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(MainFeature.Tab.profile)
        }
        .overlay(alignment: .bottom) { addButton }
        .sheet(item: $store.scope(state: \.add, action: \.add)) { store in
            AddView(store: store)
        }
    }

    private var addButton: some View {
        Button {
            store.send(.addTapped)
        } label: {
            Circle()
                .fill(HSColor.coral)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                )
                .shadow(color: HSColor.coral.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add analysis")
        .padding(.bottom, 2)
    }
}
