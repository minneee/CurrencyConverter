//
//  FetchExchangeRatesUseCaseProtocol.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import Foundation

/// "환율을 불러오는 기능"을 표현하는 UseCase 프로토콜
/// - UseCase는 Domain 계층에서 "앱이 제공해야 하는 기능"을 정의합니다.
/// - 구체적인 구현(네트워크 통신 등)은 몰라도 됩니다.
/// - Presentation 계층(ViewModel 등)은 이 UseCase만 알면 됩니다.
public protocol FetchExchangeRatesUseCaseProtocol {
  /// 환율 데이터를 불러오는 기능
  func execute() async throws -> [ExchangeRate]
}
