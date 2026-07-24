//
//  HomeView.swift
//  Healthside
//

import ComposableArchitecture
import SwiftUI

struct HomeView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    content
                }
                .padding(20)
            }
            .background(HSColor.background)
            .toolbar(.hidden, for: .navigationBar)
            .refreshable { await store.send(.refresh).finish() }
        }
        .task { await store.send(.task).finish() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Date.now.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(HSColor.inkSecondary)
            Text("Hi 👋")
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.5)
                .foregroundStyle(HSColor.ink)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if store.isLoading, store.documents.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 240)
        } else if let error = store.loadError, store.documents.isEmpty {
            errorState(error)
        } else if store.isEmpty {
            emptyState
        } else {
            if let summary = store.latestSummary {
                summaryCard(summary)
            }
            recentRecords
        }
    }

    private func summaryCard(_ document: DocumentDTO) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HSStatusBadge("Latest", systemImage: "sparkles", kind: .success)
            Text(document.summary ?? "")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(HSColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(document.displayTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(HSColor.inkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(HSColor.surface))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(HSColor.hairline, lineWidth: 1))
    }

    private var recentRecords: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT RECORDS")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.06 * 12)
                .foregroundStyle(HSColor.labelDisabled)

            ForEach(store.recentDocuments) { document in
                DocumentRow(document)
            }
        }
    }

    // MARK: - Empty / error

    private var emptyState: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 26)
                .fill(HSColor.coralSoft)
                .frame(width: 96, height: 96)
                .overlay(
                    Image(systemName: "drop.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(HSColor.coral)
                )
            Text("Add your first analysis")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(HSColor.ink)
            Text("Snap a photo of a lab result and we'll explain it in plain language.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HSColor.inkSecondary)
                .multilineTextAlignment(.center)
            HSButton("Add analysis") {
                store.send(.addAnalysisTapped)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HSColor.inkSecondary)
                .multilineTextAlignment(.center)
            HSButton("Try again", style: .secondary) {
                store.send(.refresh)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
