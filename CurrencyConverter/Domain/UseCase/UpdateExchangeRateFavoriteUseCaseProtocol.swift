//
//  UpdateExchangeRateFavoriteUseCaseProtocol.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

import Foundation

protocol UpdateExchangeRateFavoriteUseCaseProtocol {
  func execute(currencyCode: String, isFavorite: Bool) async throws
}

