//
//  UserViewStateRepositoryProtocol.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

import Foundation

public protocol UserViewStateRepositoryProtocol {
  func fetchLastSeenState() throws -> AppViewState?
  func updateLastSeenScreen(_ screen: AppViewState.Screen) throws
}
