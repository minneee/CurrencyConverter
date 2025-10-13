//
//  CoreDataExchangeRateStorage.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/2/25.
//

import CoreData
import Foundation

struct PersistedExchangeRate {
  let currencyCode: String
  let rate: Double
  let previousRate: Double?
  let isFavorite: Bool
  let lastUpdated: Date
  let changeDirection: Int16
}

final class CoreDataExchangeRateStorage {
  private enum Keys {
    static let entityName = "ExchangeRateEntity"
    static let baseCode = "baseCode"
    static let changeDirection = "changeDirection"
    static let id = "id"
    static let isFavorite = "isFavorite"
    static let lastUpdated = "lastUpdated"
    static let latestRate = "latestRate"
    static let previousRate = "previousRate"
    static let quoteCode = "quoteCode"
  }

  private let container: NSPersistentContainer
  private let calendar: Calendar

  init(container: NSPersistentContainer, calendar: Calendar = .current) {
    self.container = container
    self.calendar = calendar
  }

  func fetchRates(for date: Date) throws -> [PersistedExchangeRate] {
    let context = container.viewContext
    let startOfDay = calendar.startOfDay(for: date)
    guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }

    let request = NSFetchRequest<NSManagedObject>(entityName: Keys.entityName)
    request.predicate = NSPredicate(
      format: "%K >= %@ AND %K < %@",
      Keys.lastUpdated,
      startOfDay as NSDate,
      Keys.lastUpdated,
      endOfDay as NSDate
    )
    request.sortDescriptors = [
      NSSortDescriptor(key: Keys.isFavorite, ascending: false),
      NSSortDescriptor(key: Keys.quoteCode, ascending: true)
    ]

    let rates = try context.performAndWaitThrowing { () throws -> [PersistedExchangeRate] in
      try context.fetch(request).compactMap(self.makePersistedExchangeRate(from:))
    }

    let formatter = ISO8601DateFormatter()
    print(
      "[CoreData환율 조회] - 날짜: \(formatter.string(from: startOfDay)), 결과: \(rates.count)건"
    )
    return rates
  }

  func fetchRate(for currencyCode: String) throws -> PersistedExchangeRate? {
    let context = container.viewContext
    let request = NSFetchRequest<NSManagedObject>(entityName: Keys.entityName)
    request.predicate = NSPredicate(format: "%K == %@", Keys.quoteCode, currencyCode)
    request.fetchLimit = 1

    return try context.performAndWaitThrowing { () throws -> PersistedExchangeRate? in
      guard let object = try context.fetch(request).first else { return nil }
      return self.makePersistedExchangeRate(from: object)
    }
  }

  func upsert(baseCode: String, rates: [String: Double], timestamp: Date) throws {
    guard !rates.isEmpty else {
      print("[CoreData환율] upsert 생략 - 기준통화: \(baseCode), 입력 데이터 없음")
      return
    }
    let context = container.newBackgroundContext()
    let normalizedDate = calendar.startOfDay(for: timestamp)

    let metrics = try context.performAndWaitThrowing { () throws -> (inserted: Int, updated: Int, deleted: Int) in
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Keys.entityName)
      let existingObjects = try context.fetch(fetchRequest)

      var existingByCode: [String: NSManagedObject] = [:]
      existingObjects.forEach { object in
        if let code = object.value(forKey: Keys.quoteCode) as? String {
          existingByCode[code] = object
        }
      }

      var insertedCount = 0
      var updatedCount = 0

      for (code, rate) in rates {
        let managedObject: NSManagedObject
        let isExisting: Bool
        if let existing = existingByCode.removeValue(forKey: code) {
          managedObject = existing
          isExisting = true
          updatedCount += 1
        } else {
          managedObject = NSEntityDescription.insertNewObject(
            forEntityName: Keys.entityName,
            into: context
          )
          managedObject.setValue(UUID(), forKey: Keys.id)
          managedObject.setValue(false, forKey: Keys.isFavorite)
          isExisting = false
          insertedCount += 1
        }

        managedObject.setValue(baseCode, forKey: Keys.baseCode)
        managedObject.setValue(code, forKey: Keys.quoteCode)
        managedObject.setValue(normalizedDate, forKey: Keys.lastUpdated)

        let latestRate = NSDecimalNumber(value: rate)
        if isExisting, let previousLatest = managedObject.value(forKey: Keys.latestRate) as? NSDecimalNumber {
          managedObject.setValue(previousLatest, forKey: Keys.previousRate)

          let previousValue = previousLatest.doubleValue
          let latestValue = rate
          let delta = latestValue - previousValue
          let changeDirection: Int16
          if abs(delta) > 0.01 {
            changeDirection = delta > 0 ? 1 : -1
          } else {
            changeDirection = 0
          }
          managedObject.setValue(changeDirection, forKey: Keys.changeDirection)
        } else {
          managedObject.setValue(latestRate, forKey: Keys.previousRate)
          managedObject.setValue(0, forKey: Keys.changeDirection)
        }

        managedObject.setValue(latestRate, forKey: Keys.latestRate)
      }

      let deletedCount = existingByCode.count
      existingByCode.values.forEach(context.delete)

      if context.hasChanges {
        try context.save()
      }
      return (insertedCount, updatedCount, deletedCount)
    }

    let formatter = ISO8601DateFormatter()
    print(
      "[CoreData환율] upsert 완료 - 기준통화: \(baseCode), 날짜: \(formatter.string(from: normalizedDate)), 추가: \(metrics.inserted)건, 갱신: \(metrics.updated)건, 삭제: \(metrics.deleted)건"
    )
  }

  func updateFavorite(for currencyCode: String, isFavorite: Bool) async throws {
    let context = container.newBackgroundContext()
    try await context.perform {
      let request = NSFetchRequest<NSManagedObject>(entityName: Keys.entityName)
      request.predicate = NSPredicate(format: "%K == %@", Keys.quoteCode, currencyCode)
      request.fetchLimit = 1

      guard let managedObject = try context.fetch(request).first else { return }

      managedObject.setValue(isFavorite, forKey: Keys.isFavorite)

      if context.hasChanges {
        try context.save()
      }
    }
  }
}

private extension CoreDataExchangeRateStorage {
  func makePersistedExchangeRate(from object: NSManagedObject) -> PersistedExchangeRate? {
    guard
      let code = object.value(forKey: Keys.quoteCode) as? String,
      let rateNumber = object.value(forKey: Keys.latestRate) as? NSDecimalNumber,
      let lastUpdated = object.value(forKey: Keys.lastUpdated) as? Date
    else {
      return nil
    }

    let isFavorite = object.value(forKey: Keys.isFavorite) as? Bool ?? false
    let changeDirection = object.value(forKey: Keys.changeDirection) as? Int16 ?? 0
    let previousRateNumber = object.value(forKey: Keys.previousRate) as? NSDecimalNumber

    return PersistedExchangeRate(
      currencyCode: code,
      rate: rateNumber.doubleValue,
      previousRate: previousRateNumber?.doubleValue,
      isFavorite: isFavorite,
      lastUpdated: lastUpdated,
      changeDirection: changeDirection
    )
  }
}

private extension NSManagedObjectContext {
  func performAndWaitThrowing<T>(_ work: () throws -> T) throws -> T {
    var result: Result<T, Error>!
    performAndWait {
      do {
        result = .success(try work())
      } catch {
        result = .failure(error)
      }
    }
    return try result.get()
  }
}
