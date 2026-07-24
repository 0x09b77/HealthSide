//
//  BiomarkerView.swift
//  Healthside
//

import Charts
import ComposableArchitecture
import SwiftUI

struct BiomarkerView: View {
    let store: StoreOf<BiomarkerFeature>

    private var series: BiomarkerSeries { store.series }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                if series.measurements.count > 1 {
                    chartCard
                }
                trendNote
                sources
            }
            .padding(20)
        }
        .background(HSColor.background)
        .navigationTitle(series.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Шапка

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(series.name)
                .font(.system(size: 24, weight: .heavy))
                .tracking(-0.4)
                .foregroundStyle(HSColor.ink)

            HStack(spacing: 10) {
                Text(series.displayValue)
                    .font(.system(size: 32, weight: .heavy))
                    .monospacedDigit()
                    .foregroundStyle(HSColor.ink)
                biomarkerStatusBadge(series.status)
            }
        }
    }

    // MARK: - График

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Chart {
                // Зона нормы — только если бэкенд отдал референс.
                if let low = series.referenceLow, let high = series.referenceHigh {
                    RectangleMark(
                        yStart: .value("Reference low", low),
                        yEnd: .value("Reference high", high)
                    )
                    .foregroundStyle(HSColor.successFill)
                }

                ForEach(series.measurements) { measurement in
                    LineMark(
                        x: .value("Date", measurement.date),
                        y: .value("Value", measurement.value)
                    )
                    .foregroundStyle(HSColor.coral)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", measurement.date),
                        y: .value("Value", measurement.value)
                    )
                    .foregroundStyle(HSColor.coral)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                    AxisGridLine().foregroundStyle(HSColor.hairline)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                    AxisGridLine().foregroundStyle(HSColor.hairline)
                }
            }
            .frame(height: 190)

            if series.hasReferenceRange {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(HSColor.successFill)
                        .frame(width: 18, height: 10)
                    Text("Normal range")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(HSColor.inkSecondary)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(HSColor.surface))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(HSColor.hairline, lineWidth: 1))
    }

    // MARK: - Тренд

    private var trendNote: some View {
        Text(trendText)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(HSColor.inkSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var trendText: String {
        guard let previous = series.previous, let latest = series.latest else {
            return "Only one measurement so far — add more results to see a trend."
        }
        let since = previous.date.formatted(.dateTime.month(.abbreviated).year())
        return switch series.trend {
        case .up: "Trending up since \(since) (was \(BiomarkerRow.format(previous.value)))."
        case .down: "Trending down since \(since) (was \(BiomarkerRow.format(previous.value)))."
        case .stable: "Steady since \(since)."
        case .unknown: "Latest reading from \(latest.date.formatted(.dateTime.month(.abbreviated).year()))."
        }
    }

    // MARK: - Источники

    private var sources: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SOURCES")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.72)
                .foregroundStyle(HSColor.labelDisabled)

            VStack(spacing: 8) {
                ForEach(series.measurements.reversed()) { measurement in
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(measurement.documentTitle)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(HSColor.ink)
                            Text(measurement.date.formatted(.dateTime.month(.abbreviated).day().year()))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(HSColor.inkSecondary)
                        }
                        Spacer(minLength: 8)
                        Text([BiomarkerRow.format(measurement.value), series.unit]
                            .compactMap { $0 }
                            .joined(separator: " "))
                            .font(.system(size: 14, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(HSColor.ink)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(HSColor.surface))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(HSColor.hairline, lineWidth: 1))
                }
            }
        }
    }
}
