//
//  UpdateExchangeRateFavoriteUseCase.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

struct UpdateExchangeRateFavoriteUseCase: UpdateExchangeRateFavoriteUseCaseProtocol {
  private let repository: ExchangeRateRepositoryProtocol

  init(repository: ExchangeRateRepositoryProtocol) {
    self.repository = repository
  }

  func execute(currencyCode: String, isFavorite: Bool) async throws {
    try await repository.updateFavorite(currencyCode: currencyCode, isFavorite: isFavorite)
  }
}

