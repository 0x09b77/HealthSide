//
//  InsightsView.swift
//  Healthside
//

import ComposableArchitecture
import SwiftUI

struct InsightsView: View {
    @Bindable var store: StoreOf<InsightsFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            content
                .background(HSColor.background)
                .navigationTitle("Insights")
        } destination: { store in
            switch store.case {
            case let .biomarker(store):
                BiomarkerView(store: store)
            }
        }
        .task { store.send(.task) }
    }

    @ViewBuilder
    private var content: some View {
        if store.isLoading, store.documents.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = store.loadError, store.documents.isEmpty {
            errorState(error)
        } else if store.isEmpty {
            emptyState
        } else {
            markersList
        }
    }

    private var markersList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !store.worthWatching.isEmpty {
                    section("WORTH WATCHING", series: store.worthWatching)
                }
                section("ALL MARKERS", series: store.series)
            }
            .padding(20)
        }
        .refreshable { await store.send(.refresh).finish() }
    }

    private func section(_ title: String, series: [BiomarkerSeries]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .tracking(0.72)
                .foregroundStyle(HSColor.labelDisabled)

            VStack(spacing: 8) {
                ForEach(series) { item in
                    Button {
                        store.send(.seriesTapped(item))
                    } label: {
                        BiomarkerSeriesRow(series: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("No trends yet")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(HSColor.ink)
            Text("Add a couple of lab results and your trends will show up here.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HSColor.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 60)
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
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 60)
    }
}

/// Строка маркера: имя · последнее значение · стрелка тренда · статус.
struct BiomarkerSeriesRow: View {
    let series: BiomarkerSeries

    var body: some View {
        HStack(spacing: 10) {
            Text(series.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HSColor.ink)
                .lineLimit(1)

            Spacer(minLength: 8)

            if let symbol = trendSymbol {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(HSColor.inkSecondary)
            }

            Text(series.displayValue)
                .font(.system(size: 15, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(HSColor.ink)

            biomarkerStatusBadge(series.status)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(HSColor.surface))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(HSColor.hairline, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(series.name), \(series.displayValue), \(statusWord)")
    }

    private var trendSymbol: String? {
        switch series.trend {
        case .up: "arrow.up.right"
        case .down: "arrow.down.right"
        case .stable: "arrow.right"
        case .unknown: nil
        }
    }

    private var statusWord: String {
        switch series.status {
        case .normal: "normal"
        case .high: "above range"
        case .low: "below range"
        case .critical: "critical"
        case .unknown: "unknown"
        }
    }
}

@ViewBuilder
func biomarkerStatusBadge(_ status: BiomarkerStatus) -> some View {
    switch status {
    case .normal:
        HSStatusBadge("Normal", systemImage: "checkmark", kind: .success)
    case .high:
        HSStatusBadge("Above", systemImage: "arrow.up", kind: .warning)
    case .low:
        HSStatusBadge("Below", systemImage: "arrow.down", kind: .warning)
    case .critical:
        HSStatusBadge("Critical", systemImage: "exclamationmark.triangle", kind: .danger)
    case .unknown:
        EmptyView()
    }
}
