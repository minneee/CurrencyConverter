//
//  MockExchangeRateRepository.swift
//  CurrencyConverter
//
//  Created by Minhee's Assistant on 2024-10-09.
//

import Foundation

/// In-memory mock that mimics the live repository so the UI can be
/// exercised without hitting the network. Each call to
/// `fetchExchangeRates()` advances to the next scenario so that pull to
/// refresh can demonstrate trend changes.
final class MockExchangeRateRepository: ExchangeRateRepositoryProtocol {
  struct Scenario: Decodable {
    let name: String
    let rates: [String: Double]
  }

  enum MockError: Error, LocalizedError {
    case noScenarios

    var errorDescription: String? {
      switch self {
      case .noScenarios:
        return "Mock 시나리오를 불러오지 못했습니다."
      }
    }
  }

  private let scenarios: [Scenario]
  private let cycleScenarios: Bool

  private var currentIndex: Int = 0
  private var lastRatesByCode: [String: Double] = [:]
  private var lastSnapshot: [ExchangeRate] = []
  private var favorites: Set<String> = []

  init(
    bundle: Bundle = .main,
    resourceName: String = "MockExchangeRates",
    cycleScenarios: Bool = true
  ) {
    self.cycleScenarios = cycleScenarios
    if
      let url = bundle.url(forResource: resourceName, withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let decoded = try? JSONDecoder().decode([Scenario].self, from: data),
      !decoded.isEmpty
    {
      self.scenarios = decoded
    } else {
      self.scenarios = Self.defaultScenarios
    }
  }

  func fetchExchangeRates() async throws -> [ExchangeRate] {
    guard !scenarios.isEmpty else { throw MockError.noScenarios }

    let scenario = scenarios[currentIndex]
    var nextSnapshot: [ExchangeRate] = []
    nextSnapshot.reserveCapacity(scenario.rates.count)

    for (code, rate) in scenario.rates {
      let previous = lastRatesByCode[code]
      let isFavorite = favorites.contains(code)
      nextSnapshot.append(
        ExchangeRate(
          currencyCode: code,
          rate: rate,
          previousRate: previous,
          isFavorite: isFavorite
        )
      )
    }

    lastRatesByCode = scenario.rates
    lastSnapshot = sort(nextSnapshot)
    advanceScenarioIndex()
    return lastSnapshot
  }

  func fetchPersistedExchangeRate(currencyCode: String) throws -> ExchangeRate? {
    if let cached = lastSnapshot.first(where: { $0.currencyCode == currencyCode }) {
      return cached
    }

    guard let scenario = scenarios.first, let rate = scenario.rates[currencyCode] else {
      return nil
    }

    return ExchangeRate(
      currencyCode: currencyCode,
      rate: rate,
      previousRate: nil,
      isFavorite: favorites.contains(currencyCode)
    )
  }

  func updateFavorite(currencyCode: String, isFavorite: Bool) async throws {
    if isFavorite {
      favorites.insert(currencyCode)
    } else {
      favorites.remove(currencyCode)
    }

    if let index = lastSnapshot.firstIndex(where: { $0.currencyCode == currencyCode }) {
      let existing = lastSnapshot[index]
      lastSnapshot[index] = ExchangeRate(
        currencyCode: existing.currencyCode,
        rate: existing.rate,
        previousRate: existing.previousRate,
        isFavorite: isFavorite
      )
      lastSnapshot = sort(lastSnapshot)
    }
  }
}

private extension MockExchangeRateRepository {
  func advanceScenarioIndex() {
    guard !scenarios.isEmpty else { return }
    if cycleScenarios {
      currentIndex = (currentIndex + 1) % scenarios.count
    } else {
      currentIndex = min(currentIndex + 1, scenarios.count - 1)
    }
  }

  func sort(_ rates: [ExchangeRate]) -> [ExchangeRate] {
    rates.sorted { lhs, rhs in
      if lhs.isFavorite != rhs.isFavorite {
        return lhs.isFavorite && !rhs.isFavorite
      }
      return lhs.currencyCode < rhs.currencyCode
    }
  }

  static var defaultScenarios: [Scenario] {
    [
      Scenario(
        name: "Baseline",
        rates: [
          "USD": 1.0,
          "KRW": 1362.45,
          "JPY": 149.23,
          "EUR": 0.92,
          "GBP": 0.79,
          "CNY": 7.19
        ]
      ),
      Scenario(
        name: "After Market Open",
        rates: [
          "USD": 1.0,
          "KRW": 1374.15,
          "JPY": 148.01,
          "EUR": 0.93,
          "GBP": 0.78,
          "CNY": 7.25
        ]
      ),
      Scenario(
        name: "Closing",
        rates: [
          "USD": 1.0,
          "KRW": 1355.72,
          "JPY": 150.04,
          "EUR": 0.91,
          "GBP": 0.80,
          "CNY": 7.18
        ]
      )
    ]
  }
}
