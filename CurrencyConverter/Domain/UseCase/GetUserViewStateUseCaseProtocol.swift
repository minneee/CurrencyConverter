//
//  GetUserViewStateUseCaseProtocol.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

import Foundation

protocol GetUserViewStateUseCaseProtocol {
  func execute() throws -> AppViewState?
}
