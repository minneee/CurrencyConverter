//
//  ExchangeRateViewModel.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/29/25.
//

import Foundation

@MainActor
final class ExchangeRateViewModel: ViewModelProtocol {
  /// Action, State 정의
  enum Action {
    case appear
    case refresh
    case search(String)
    case toggleFavorite(currencyCode: String, isFavorite: Bool)
    case dismissError
  }

  struct State {
    struct ExchangeRateRow {
      let exchangeRate: ExchangeRate
      let countryName: String?
    }

    var exchangeRates: [ExchangeRateRow]
    var isLoading: Bool
    var errorMessage: String?
    var searchQuery: String

    static let initial = State(
      exchangeRates: [],
      isLoading: false,
      errorMessage: nil,
      searchQuery: ""
    )
  }

  var action: ((Action) -> Void)? { handleAction }

  private(set) var state: State {
    didSet { stateDidChange?(state) }
  }

  var stateDidChange: ((State) -> Void)? {
    didSet { stateDidChange?(state) }
  }

  private lazy var handleAction: (Action) -> Void = { [weak self] action in
    Task { await self?.handle(action) }
  }

  private let fetchExchangeRatesUseCase: FetchExchangeRatesUseCaseProtocol
  private let getCountryNameUseCase: GetCountryNameUseCaseProtocol
  private let updateFavoriteUseCase: UpdateExchangeRateFavoriteUseCaseProtocol

  private var allExchangeRates: [State.ExchangeRateRow] = []

  init(
    fetchExchangeRatesUseCase: FetchExchangeRatesUseCaseProtocol,
    getCountryNameUseCase: GetCountryNameUseCaseProtocol,
    updateFavoriteUseCase: UpdateExchangeRateFavoriteUseCaseProtocol
  ) {
    self.fetchExchangeRatesUseCase = fetchExchangeRatesUseCase
    self.getCountryNameUseCase = getCountryNameUseCase
    self.updateFavoriteUseCase = updateFavoriteUseCase
    self.state = .initial

  }

  private func handle(_ action: Action) async {
    switch action {
    case .appear, .refresh:
      await loadExchangeRates()
    case .search(let query):
      filterExchangeRates(with: query)
    case .toggleFavorite(let currencyCode, let isFavorite):
      await toggleFavorite(currencyCode: currencyCode, isFavorite: isFavorite)
    case .dismissError:
      setState { $0.errorMessage = nil }
    }
  }

  private func loadExchangeRates() async {
    guard !state.isLoading else { return }

    setState {
      $0.isLoading = true
      $0.errorMessage = nil
    }

    do {
      let rates = try await fetchExchangeRatesUseCase.execute()
      let rows = buildRows(from: rates)
      let sortedRows = sortRows(rows)
      allExchangeRates = sortedRows

      let filtered = filteredRows(with: state.searchQuery, from: sortedRows)
      setState {
        $0.isLoading = false
        $0.exchangeRates = filtered
      }
    } catch {
      setState {
        $0.isLoading = false
        $0.exchangeRates = []
        $0.errorMessage = error.localizedDescription
      }
    }
  }

  private func filterExchangeRates(with query: String) {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    let filtered = filteredRows(with: trimmed, from: allExchangeRates)

    setState {
      $0.searchQuery = trimmed
      $0.exchangeRates = filtered
    }
  }

  private func buildRows(from rates: [ExchangeRate]) -> [State.ExchangeRateRow] {
    rates.map { rate in
      let countryName = getCountryNameUseCase.execute(currencyCode: rate.currencyCode)
      return State.ExchangeRateRow(exchangeRate: rate, countryName: countryName)
    }
  }

  private func sortRows(_ rows: [State.ExchangeRateRow]) -> [State.ExchangeRateRow] {
    rows.sorted { lhs, rhs in
      if lhs.exchangeRate.isFavorite != rhs.exchangeRate.isFavorite {
        return lhs.exchangeRate.isFavorite && !rhs.exchangeRate.isFavorite
      }
      return lhs.exchangeRate.currencyCode < rhs.exchangeRate.currencyCode
    }
  }

  private func toggleFavorite(currencyCode: String, isFavorite: Bool) async {
    let previousAllRows = allExchangeRates

    guard let index = allExchangeRates.firstIndex(where: { row in
      row.exchangeRate.currencyCode == currencyCode
    }) else {
      return
    }

    let row = allExchangeRates[index]
    let updatedExchangeRate = ExchangeRate(
      currencyCode: row.exchangeRate.currencyCode,
      rate: row.exchangeRate.rate,
      isFavorite: isFavorite
    )
    let updatedRow = State.ExchangeRateRow(
      exchangeRate: updatedExchangeRate,
      countryName: row.countryName
    )

    allExchangeRates[index] = updatedRow
    allExchangeRates = sortRows(allExchangeRates)

    let filtered = filteredRows(with: state.searchQuery, from: allExchangeRates)
    setState { $0.exchangeRates = filtered }

    do {
      try await updateFavoriteUseCase.execute(currencyCode: currencyCode, isFavorite: isFavorite)
    } catch {
      allExchangeRates = previousAllRows
      let restored = filteredRows(with: state.searchQuery, from: allExchangeRates)
      setState {
        $0.exchangeRates = restored
        $0.errorMessage = error.localizedDescription
      }
    }
  }

  private func filteredRows(
    with query: String,
    from rows: [State.ExchangeRateRow]
  ) -> [State.ExchangeRateRow] {
    guard !query.isEmpty else { return rows }

    let keyword = query.lowercased()
    return rows.filter { row in
      let codeMatches = row.exchangeRate.currencyCode.lowercased().contains(keyword)
      let countryMatches = row.countryName?.lowercased().contains(keyword) ?? false
      return codeMatches || countryMatches
    }
  }

  func exchangeRateRow(at index: Int) -> State.ExchangeRateRow? {
    guard state.exchangeRates.indices.contains(index) else { return nil }
    return state.exchangeRates[index]
  }

  private func setState(_ mutation: (inout State) -> Void) {
    var next = state
    mutation(&next)
    state = next
  }
}
