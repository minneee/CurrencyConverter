//
//  GetUserViewStateUseCase.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

struct GetUserViewStateUseCase: GetUserViewStateUseCaseProtocol {
  private let repository: UserViewStateRepositoryProtocol

  init(repository: UserViewStateRepositoryProtocol) {
    self.repository = repository
  }

  func execute() throws -> AppViewState? {
    try repository.fetchLastSeenState()
  }
}
