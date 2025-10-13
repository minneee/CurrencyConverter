//
//  UserViewStateRepository.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

import Foundation

struct UserViewStateRepository: UserViewStateRepositoryProtocol {
  private let storage: CoreDataUserViewStateStorage

  init(storage: CoreDataUserViewStateStorage) {
    self.storage = storage
  }

  func fetchLastSeenState() throws -> AppViewState? {
    guard let persisted = try storage.fetch() else { return nil }
    return makeDomain(from: persisted)
  }

  func updateLastSeenScreen(_ screen: AppViewState.Screen) throws {
    switch screen {
    case .exchangeRateList:
      try storage.save(screen: .exchangeRateList, calculatorCurrencyCode: nil)
    case .currencyConverter(let currencyCode):
      try storage.save(screen: .currencyConverter, calculatorCurrencyCode: currencyCode)
    }
  }

  private func makeDomain(from persisted: PersistedUserViewState) -> AppViewState {
    let screen: AppViewState.Screen
    switch persisted.screen {
    case .exchangeRateList:
      screen = .exchangeRateList
    case .currencyConverter:
      if let currencyCode = persisted.calculatorCurrencyCode, !currencyCode.isEmpty {
        screen = .currencyConverter(currencyCode: currencyCode)
      } else {
        screen = .exchangeRateList
      }
    }

    return AppViewState(screen: screen, updatedAt: persisted.updatedAt)
  }
}
