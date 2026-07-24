//
//  WelcomeView.swift
//  Healthside
//

import ComposableArchitecture
import SwiftUI

struct WelcomeView: View {
    @Bindable var store: StoreOf<WelcomeFeature>

    private struct Slide: Identifiable {
        let id = UUID()
        let symbol: String
        let title: String
        let body: String
    }

    private let slides: [Slide] = [
        Slide(
            symbol: "drop.fill",
            title: "Your labs, in one calm place.",
            body: "Every result together, over time — no more scattered PDFs and photos."
        ),
        Slide(
            symbol: "camera.viewfinder",
            title: "Snap a photo, we do the rest.",
            body: "Point your camera at a lab result and Healthside reads and organizes it."
        ),
        Slide(
            symbol: "chart.xyaxis.line",
            title: "See your trends over time.",
            body: "Track biomarkers across visits and spot what's changing."
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $store.selectedPage) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                    slideView(slide).tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            dots.padding(.bottom, 28)

            HSButton("Get started") {
                store.send(.getStartedTapped)
            }

            HStack(spacing: 4) {
                Text("Have an account?")
                    .foregroundStyle(HSColor.inkSecondary)
                Button("Log in") {
                    store.send(.logInTapped)
                }
                .foregroundStyle(HSColor.coral)
            }
            .font(.system(size: 14, weight: .semibold))
            .padding(.top, 18)
        }
        .padding(24)
        .background(HSColor.background)
    }

    private func slideView(_ slide: Slide) -> some View {
        VStack(spacing: 28) {
            RoundedRectangle(cornerRadius: 30)
                .fill(HSColor.coralSoft)
                .frame(width: 124, height: 124)
                .overlay(
                    Image(systemName: slide.symbol)
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundStyle(HSColor.coral)
                )

            VStack(spacing: 12) {
                Text(slide.title)
                    .font(.system(size: 27, weight: .heavy))
                    .tracking(-0.5)
                    .foregroundStyle(HSColor.ink)

                Text(slide.body)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(HSColor.inkSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
        }
        .padding(.horizontal, 12)
    }

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(slides.indices, id: \.self) { index in
                Capsule()
                    .fill(index == store.selectedPage ? HSColor.coral : HSColor.hairline)
                    .frame(width: index == store.selectedPage ? 22 : 8, height: 8)
                    .animation(.snappy, value: store.selectedPage)
            }
        }
    }
}

#Preview {
    WelcomeView(
        store: Store(initialState: WelcomeFeature.State()) {
            WelcomeFeature()
        }
    )
}
