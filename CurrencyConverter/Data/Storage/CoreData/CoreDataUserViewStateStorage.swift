//
//  CoreDataUserViewStateStorage.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

import CoreData
import Foundation

struct PersistedUserViewState {
  enum Screen: Int16 {
    case exchangeRateList = 0
    case currencyConverter = 1
  }

  let screen: Screen
  let calculatorCurrencyCode: String?
  let updatedAt: Date?
}

final class CoreDataUserViewStateStorage {
  private enum Keys {
    static let entityName = "UserViewState"
    static let id = "id"
    static let lastSeenScreen = "lastSeenScreen"
    static let calculatorCurrencyCode = "calculatorCurrencyCode"
    static let updatedAt = "updatedAt"
  }

  private let container: NSPersistentContainer

  init(container: NSPersistentContainer) {
    self.container = container
  }

  func fetch() throws -> PersistedUserViewState? {
    let context = container.viewContext
    let request = NSFetchRequest<NSManagedObject>(entityName: Keys.entityName)
    request.fetchLimit = 1
    request.sortDescriptors = [
      NSSortDescriptor(key: Keys.updatedAt, ascending: false)
    ]

    var fetchError: Error?
    var state: PersistedUserViewState?

    context.performAndWait {
      do {
        if let object = try context.fetch(request).first {
          state = self.makePersistedState(from: object)
        }
      } catch {
        fetchError = error
      }
    }

    if let error = fetchError { throw error }
    return state
  }

  func save(screen: PersistedUserViewState.Screen, calculatorCurrencyCode: String?) throws {
    let context = container.viewContext
    let request = NSFetchRequest<NSManagedObject>(entityName: Keys.entityName)

    var saveError: Error?

    context.performAndWait {
      do {
        let objects = try context.fetch(request)
        let object: NSManagedObject
        if let first = objects.first {
          object = first
          // 정합성을 위해 나머지 레코드는 제거합니다.
          if objects.count > 1 {
            objects.dropFirst().forEach(context.delete)
          }
        } else {
          object = NSEntityDescription.insertNewObject(forEntityName: Keys.entityName, into: context)
          object.setValue(UUID(), forKey: Keys.id)
        }

        object.setValue(screen.rawValue, forKey: Keys.lastSeenScreen)
        switch screen {
        case .exchangeRateList:
          object.setValue(nil, forKey: Keys.calculatorCurrencyCode)
        case .currencyConverter:
          object.setValue(calculatorCurrencyCode, forKey: Keys.calculatorCurrencyCode)
        }
        object.setValue(Date(), forKey: Keys.updatedAt)

        if context.hasChanges {
          try context.save()
        }
      } catch {
        saveError = error
      }
    }

    if let error = saveError { throw error }
  }

  private func makePersistedState(from object: NSManagedObject) -> PersistedUserViewState? {
    guard
      let rawScreen = object.value(forKey: Keys.lastSeenScreen) as? Int16,
      let screen = PersistedUserViewState.Screen(rawValue: rawScreen)
    else {
      return nil
    }

    let currencyCode = object.value(forKey: Keys.calculatorCurrencyCode) as? String
    let updatedAt = object.value(forKey: Keys.updatedAt) as? Date

    return PersistedUserViewState(
      screen: screen,
      calculatorCurrencyCode: currencyCode,
      updatedAt: updatedAt
    )
  }
}

