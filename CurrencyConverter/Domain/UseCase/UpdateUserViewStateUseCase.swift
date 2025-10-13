//
//  UpdateUserViewStateUseCase.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

struct UpdateUserViewStateUseCase: UpdateUserViewStateUseCaseProtocol {
  private let repository: UserViewStateRepositoryProtocol

  init(repository: UserViewStateRepositoryProtocol) {
    self.repository = repository
  }

  func execute(screen: AppViewState.Screen) throws {
    try repository.updateLastSeenScreen(screen)
  }
}
