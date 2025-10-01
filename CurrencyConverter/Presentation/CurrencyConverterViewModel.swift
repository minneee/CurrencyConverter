//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/1/25.
//

import Foundation

final class CurrencyConverterViewModel {
  let exchangeRate: ExchangeRate
  let countryName: String

  init(exchangeRate: ExchangeRate, countryName: String) {
    self.exchangeRate = exchangeRate
    self.countryName = countryName
  }

  func convert(amount: Double) -> Double {
    amount * exchangeRate.rate
  }
}
