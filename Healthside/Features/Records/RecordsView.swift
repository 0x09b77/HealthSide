//
//  RecordsView.swift
//  Healthside
//

import ComposableArchitecture
import SwiftUI

struct RecordsView: View {
    @Bindable var store: StoreOf<RecordsFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack(spacing: 0) {
                Picker("Filter", selection: $store.filter) {
                    ForEach(RecordsFeature.State.Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                content
            }
            .background(HSColor.background)
            .navigationTitle("Records")
            .searchable(text: $store.searchText, prompt: "Search")
        } destination: { store in
            switch store.case {
            case let .document(store):
                DocumentView(store: store)
            }
        }
        .task { await store.send(.task).finish() }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if store.isLoading, store.documents.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = store.loadError, store.documents.isEmpty {
            errorState(error)
        } else if store.isEmpty {
            emptyState(
                title: "No records yet",
                message: "Add a lab result and it will show up here."
            )
        } else if store.filteredDocuments.isEmpty {
            emptyState(
                title: "Nothing found",
                message: "Try a different search or filter."
            )
        } else {
            timeline
        }
    }

    private var timeline: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedDocuments, id: \.title) { group in
                    Section {
                        VStack(spacing: 10) {
                            ForEach(group.documents) { document in
                                Button {
                                    store.send(.documentTapped(document))
                                } label: {
                                    DocumentRow(document)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } header: {
                        Text(group.title)
                            .font(.system(size: 12, weight: .bold))
                            .tracking(0.72)
                            .foregroundStyle(HSColor.labelDisabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 6)
                            .background(HSColor.background)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .refreshable { await store.send(.refresh).finish() }
    }

    // MARK: - Empty / error

    private func emptyState(title: String, message: String) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(HSColor.ink)
            Text(message)
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

    // MARK: - Grouping

    private struct DocumentGroup {
        let title: String
        let documents: [DocumentDTO]
    }

    /// Группировка по месяцу (документы уже приходят newest-first).
    private var groupedDocuments: [DocumentGroup] {
        var order: [String] = []
        var buckets: [String: [DocumentDTO]] = [:]

        for document in store.filteredDocuments {
            let date = document.reportDate ?? document.uploadedAt
            let title = date?
                .formatted(.dateTime.month(.wide).year())
                .uppercased() ?? "UNDATED"
            if buckets[title] == nil {
                buckets[title] = []
                order.append(title)
            }
            buckets[title]?.append(document)
        }

        return order.map { DocumentGroup(title: $0, documents: buckets[$0] ?? []) }
    }
}
