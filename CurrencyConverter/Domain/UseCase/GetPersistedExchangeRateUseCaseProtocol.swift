//
//  GetPersistedExchangeRateUseCaseProtocol.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

import Foundation

protocol GetPersistedExchangeRateUseCaseProtocol {
  func execute(currencyCode: String) throws -> ExchangeRate?
}

