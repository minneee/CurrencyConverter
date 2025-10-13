//
//  AppConfiguration.swift
//  CurrencyConverter
//
//  Created by Minhee's Assistant on 2024-10-09.
//

import Foundation

/// Centralised configuration flags that can be flipped without touching
/// feature code. Use the `-mockExchangeRates` launch argument or the
/// `USE_MOCK_EXCHANGE_RATES=1` environment variable to enable mock data.
enum AppConfiguration {
  static var useMockExchangeRates: Bool {
    #if DEBUG
    if ProcessInfo.processInfo.arguments.contains("-mockExchangeRates") {
      return true
    }

    if let flag = ProcessInfo.processInfo.environment["USE_MOCK_EXCHANGE_RATES"],
       ["1", "true", "yes"].contains(flag.lowercased()) {
      return true
    }

    return UserDefaults.standard.bool(forKey: "USE_MOCK_EXCHANGE_RATES")
    #else
    return false
    #endif
  }
}
