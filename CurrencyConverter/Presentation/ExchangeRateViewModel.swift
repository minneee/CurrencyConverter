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
  private let fetchExchangeRatesUseCaseProtocol: FetchExchangeRatesUseCaseProtocol

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
  
  init(fetchExchangeRatesUseCaseProtocol: FetchExchangeRatesUseCaseProtocol) {
    self.fetchExchangeRatesUseCaseProtocol = fetchExchangeRatesUseCaseProtocol
  }
  
  /// 환율 데이터 로드
  func loadExchangeRates() {
    isLoading = true
    
    Task {
      do {
        let rates = try await fetchExchangeRatesUseCaseProtocol.execute()
        exchangeRates = rates
      } catch {
        errorMessage = error.localizedDescription
      }
      isLoading = false
    }
  }
}
