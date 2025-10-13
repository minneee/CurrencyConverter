//
//  GetCountryNameUseCaseProtocol.swift
//  CurrencyConverter
//
//  Created by AI on 2024-10-07.
//

import Foundation

protocol GetCountryNameUseCaseProtocol {
  func execute(currencyCode: String) -> String?
}
