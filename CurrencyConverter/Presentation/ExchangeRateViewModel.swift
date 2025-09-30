//
//  ExchangeRateViewModel.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/29/25.
//

import Foundation

/// ViewModel: View와 Repository 사이에서 "중간 다리" 역할
@MainActor
final class ExchangeRateViewModel {
  private let fetchExchangeRatesUseCase: FetchExchangeRatesUseCaseProtocol
  private let getCountryNameUseCase: GetCountryNameUseCaseProtocol

  private var allExchangeRates: [ExchangeRate] = []
  /// 현재 화면에서 보여줄 환율 데이터
  private(set) var exchangeRates: [ExchangeRate] = [] {
    didSet { onUpdate?() }
  }
  
  /// 로딩 상태
  private(set) var isLoading: Bool = false {
    didSet { onLoadingStateChange?(isLoading) }
  }
  
  /// 에러 메시지
  private(set) var errorMessage: String? {
    didSet { if let errorMessage = errorMessage { onError?(errorMessage) } }
  }
  
  var onUpdate: (() -> Void)?
  var onLoadingStateChange: ((Bool) -> Void)?
  var onError: ((String) -> Void)?
  
  init(
    fetchExchangeRatesUseCase: FetchExchangeRatesUseCaseProtocol,
    getCountryNameUseCase: GetCountryNameUseCaseProtocol
  ) {
    self.fetchExchangeRatesUseCase = fetchExchangeRatesUseCase
    self.getCountryNameUseCase = getCountryNameUseCase
  }
  
  /// 환율 데이터 로드
  func loadExchangeRates() {
    isLoading = true
    
    Task {
      do {
        let rates = try await fetchExchangeRatesUseCase.execute()
        allExchangeRates = rates
        exchangeRates = rates
      } catch {
        errorMessage = error.localizedDescription
      }
      isLoading = false
    }
  }

  func countryName(currencyCode: String) -> String? {
    getCountryNameUseCase.execute(currencyCode: currencyCode)
  }

  /// 검색어에 맞춰 환율 데이터를 필터링합니다.
  func filterExchangeRates(with query: String) {
    let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedQuery.isEmpty else {
      exchangeRates = allExchangeRates
      return
    }

    let lowercasedQuery = trimmedQuery.lowercased()

    exchangeRates = allExchangeRates.filter { rate in
      let matchesCurrencyCode = rate.currencyCode.lowercased().contains(lowercasedQuery)
      let countryName = countryName(currencyCode: rate.currencyCode)?.lowercased() ?? ""
      let matchesCountryName = countryName.contains(lowercasedQuery)

      return matchesCurrencyCode || matchesCountryName
    }
  }
}
