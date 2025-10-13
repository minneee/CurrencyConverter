//
//  AppViewState.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

import Foundation

public struct AppViewState {
  public enum Screen: Equatable {
    case exchangeRateList
    case currencyConverter(currencyCode: String)
  }

  public let screen: Screen
  public let updatedAt: Date?

  public init(screen: Screen, updatedAt: Date?) {
    self.screen = screen
    self.updatedAt = updatedAt
  }
}

