//
//  FetchExchangeRatesUseCase.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/30/25.
//

import Foundation

/// UseCase 구현체
/// - Repository를 통해 실제 데이터를 요청합니다.
struct FetchExchangeRatesUseCase: FetchExchangeRatesUseCaseProtocol {
  private let repository: ExchangeRateRepositoryProtocol

  init(repository: ExchangeRateRepositoryProtocol) {
    self.repository = repository
  }

  func execute() async throws -> [ExchangeRate] {
    return try await repository.fetchExchangeRates()
  }
}
