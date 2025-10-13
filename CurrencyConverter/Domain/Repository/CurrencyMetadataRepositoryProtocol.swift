//
//  CurrencyMetadataRepositoryProtocol.swift
//  CurrencyConverter
//
//  Created by AI on 2024-10-07.
//

import Foundation

protocol CurrencyMetadataRepositoryProtocol {
  /// 통화 코드에 대응하는 국가 이름을 반환합니다.
  /// 존재하지 않으면 nil을 반환합니다.
  func countryName(currencyCode: String) -> String?
}
