//
//  CurrencyMetadataRepository.swift
//  CurrencyConverter
//
//  Created by AI on 2024-10-07.
//

import Foundation

final class CurrencyMetadataRepository: CurrencyMetadataRepositoryProtocol {
  private let bundle: Bundle
  private var cachedCountryMap: [String: String]?
  
  init(bundle: Bundle = .main) {
    self.bundle = bundle
  }
  
  func countryName(currencyCode: String) -> String? {
    /// 이전에 불러온 내용이 있는지 확인
    if cachedCountryMap == nil {
      cachedCountryMap = loadCurrencyMap()
    }
    return cachedCountryMap?[currencyCode.uppercased()]
  }
  
  private func loadCurrencyMap() -> [String: String]? {
    guard let url = bundle.url(forResource: "CurrencyCountries", withExtension: "json") else {
      assertionFailure("CurrencyCountries.json 파일을 찾을 수 없습니다.")
      return nil
    }
    do {
      let data = try Data(contentsOf: url)
      return try JSONDecoder().decode([String: String].self, from: data)
    } catch {
      assertionFailure("CurrencyCountries.json 로딩에 실패했습니다: \(error)")
      return nil
    }
  }
}
