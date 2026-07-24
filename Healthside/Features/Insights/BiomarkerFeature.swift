//
//  BiomarkerFeature.swift
//  Healthside
//
//  Деталь биомаркера: тренд по времени. Данные приходят готовой серией,
//  дозагружать нечего.
//

import ComposableArchitecture

@Reducer
struct BiomarkerFeature {

    @ObservableState
    struct State: Equatable {
        var series: BiomarkerSeries

        init(series: BiomarkerSeries) {
            self.series = series
        }
    }

    enum Action {
        // TODO: тап по источнику → Document detail (кросс-таб навигация).
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {}
        }
    }
}
