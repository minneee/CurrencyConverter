//
//  ExchangeRateRepositoryProtocol.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import Foundation

/// Repository 프로토콜
/// - Domain 계층이 데이터를 요청할 때 사용하는 인터페이스입니다.
/// - 구체적인 구현은 Data 계층에서 담당합니다.
public protocol ExchangeRateRepositoryProtocol {
  func fetchExchangeRates() async throws -> [ExchangeRate]
  func fetchPersistedExchangeRate(currencyCode: String) throws -> ExchangeRate?
  func updateFavorite(currencyCode: String, isFavorite: Bool) async throws
}
