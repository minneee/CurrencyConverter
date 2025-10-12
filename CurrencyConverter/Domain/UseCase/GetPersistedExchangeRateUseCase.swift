//
//  GetPersistedExchangeRateUseCase.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

struct GetPersistedExchangeRateUseCase: GetPersistedExchangeRateUseCaseProtocol {
  private let repository: ExchangeRateRepositoryProtocol

  init(repository: ExchangeRateRepositoryProtocol) {
    self.repository = repository
  }

  func execute(currencyCode: String) throws -> ExchangeRate? {
    try repository.fetchPersistedExchangeRate(currencyCode: currencyCode)
  }
}

