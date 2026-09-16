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
                .navigationTitle(L10n.Insights.title)
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
                    section(L10n.Insights.worthWatching, series: store.worthWatching)
                }
                section(L10n.Insights.allMarkers, series: store.series)
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
            Text(L10n.Insights.Empty.title)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(HSColor.ink)
            Text(L10n.Insights.Empty.body)
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
            HSButton(L10n.Shared.tryAgain, style: .secondary) {
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
        case .normal: L10n.Status.BiomarkerA11y.normal
        case .high: L10n.Status.BiomarkerA11y.high
        case .low: L10n.Status.BiomarkerA11y.low
        case .critical: L10n.Status.BiomarkerA11y.critical
        case .unknown: L10n.Status.BiomarkerA11y.unknown
        }
    }
}

@ViewBuilder
func biomarkerStatusBadge(_ status: BiomarkerStatus) -> some View {
    switch status {
    case .normal:
        HSStatusBadge(L10n.Status.Biomarker.normal, systemImage: "checkmark", kind: .success)
    case .high:
        HSStatusBadge(L10n.Status.Biomarker.high, systemImage: "arrow.up", kind: .warning)
    case .low:
        HSStatusBadge(L10n.Status.Biomarker.low, systemImage: "arrow.down", kind: .warning)
    case .critical:
        HSStatusBadge(L10n.Status.Biomarker.critical, systemImage: "exclamationmark.triangle", kind: .danger)
    case .unknown:
        EmptyView()
    }
}
