//
//  DocumentView.swift
//  Healthside
//

import ComposableArchitecture
import SwiftUI

struct DocumentView: View {
    @Bindable var store: StoreOf<DocumentFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if store.document.status == .failed {
                    failedCard
                } else {
                    if let summary = store.document.summary, !summary.isEmpty {
                        summaryCard(summary)
                    }
                    if let diagnosis = store.document.diagnosis, !diagnosis.isEmpty {
                        diagnosisCard(diagnosis)
                    }
                    if !store.biomarkers.isEmpty {
                        biomarkersSection
                    }
                }

                deleteButton
            }
            .padding(20)
        }
        .background(HSColor.background)
        .navigationTitle(store.document.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.send(.task).finish() }
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(store.document.displayTitle)
                .font(.system(size: 24, weight: .heavy))
                .tracking(-0.4)
                .foregroundStyle(HSColor.ink)

            Text(store.document.displaySubtitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(HSColor.inkSecondary)

            documentStatusBadge(store.document.status)
        }
    }

    // MARK: - Cards

    private func summaryCard(_ summary: String) -> some View {
        card {
            VStack(alignment: .leading, spacing: 8) {
                sectionLabel("SUMMARY")
                Text(summary)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(HSColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func diagnosisCard(_ diagnosis: String) -> some View {
        card {
            VStack(alignment: .leading, spacing: 8) {
                sectionLabel("DIAGNOSIS")
                Text(diagnosis)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(HSColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var failedCard: some View {
        card {
            VStack(alignment: .leading, spacing: 8) {
                Text("Couldn't read this one")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(HSColor.ink)
                Text("We couldn't read this file clearly. Your original is saved.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(HSColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var biomarkersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("RESULTS")
            VStack(spacing: 8) {
                ForEach(store.biomarkers) { marker in
                    biomarkerRow(marker)
                }
            }
        }
    }

    private func biomarkerRow(_ marker: BiomarkerRow) -> some View {
        HStack(spacing: 12) {
            Text(marker.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HSColor.ink)
            Spacer(minLength: 8)
            Text(marker.value)
                .font(.system(size: 15, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(HSColor.ink)
            biomarkerBadge(marker.status)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(HSColor.surface))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(HSColor.hairline, lineWidth: 1))
    }

    @ViewBuilder
    private func biomarkerBadge(_ status: BiomarkerStatus) -> some View {
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

    private var deleteButton: some View {
        HSButton("Delete record", style: .secondary, isLoading: store.isDeleting) {
            store.send(.deleteButtonTapped)
        }
        .padding(.top, 8)
    }

    // MARK: - Building blocks

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .tracking(0.72)
            .foregroundStyle(HSColor.labelDisabled)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 18).fill(HSColor.surface))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(HSColor.hairline, lineWidth: 1))
    }
}
