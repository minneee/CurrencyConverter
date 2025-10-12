//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import Foundation

/// 환율을 나타내는 도메인 모델
/// - Domain 계층에서는 "앱에서 다루는 순수 데이터 구조"만 정의합니다.
/// - 이 데이터는 어디서 받아왔는지(API/DB 등) 몰라도 됩니다.
public struct ExchangeRate: Equatable {
  public enum Trend: Equatable {
    case up
    case down
    case steady
  }

  public let currencyCode: String
  public let rate: Double
  public let previousRate: Double?
  public let isFavorite: Bool

  public init(
    currencyCode: String,
    rate: Double,
    previousRate: Double? = nil,
    isFavorite: Bool
  ) {
    self.currencyCode = currencyCode
    self.rate = rate
    self.previousRate = previousRate
    self.isFavorite = isFavorite
  }

  public var trend: Trend {
    guard let previousRate else { return .steady }
    let delta = rate - previousRate
    guard abs(delta) > 0.01 else { return .steady }
    return delta > 0 ? .up : .down
  }
}
