//
//  ExchangeRateResponseDTO.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import Foundation

/// API 응답 구조체
/// - 서버에서 내려주는 JSON 구조와 1:1로 매핑됩니다.
/// - Domain의 모델(ExchangeRate)과는 다르게, 여기서는 서버 응답에 맞춰 구조를 정의합니다.
struct ExchangeRateResponseDTO: Codable {
  let result: String
  let base_code: String
  let rates: [String: Double]
}
