//
//  GetCountryNameUseCase.swift
//  CurrencyConverter
//
//  Created by AI on 2024-10-07.
//

import Foundation

struct GetCountryNameUseCase: GetCountryNameUseCaseProtocol {
  private let repository: CurrencyMetadataRepositoryProtocol
  
  init(repository: CurrencyMetadataRepositoryProtocol) {
    self.repository = repository
  }
  
  func execute(currencyCode: String) -> String? {
    repository.countryName(currencyCode: currencyCode)
  }
}
