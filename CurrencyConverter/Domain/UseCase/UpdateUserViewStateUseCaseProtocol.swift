//
//  UpdateUserViewStateUseCaseProtocol.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

import Foundation

protocol UpdateUserViewStateUseCaseProtocol {
  func execute(screen: AppViewState.Screen) throws
}
