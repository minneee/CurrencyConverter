//
//  AppDelegate.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let exchangeRateStorage = CoreDataExchangeRateStorage(container: persistentContainer)
    let exchangeRateRepository = ExchangeRateRepository(localStorage: exchangeRateStorage)
    let userViewStateStorage = CoreDataUserViewStateStorage(container: persistentContainer)
    let userViewStateRepository = UserViewStateRepository(storage: userViewStateStorage)

    let fetchExchangeRatesUseCase = FetchExchangeRatesUseCase(repository: exchangeRateRepository)
    let currencyMetadataRepository = CurrencyMetadataRepository()
    let getCountryNameUseCase = GetCountryNameUseCase(repository: currencyMetadataRepository)
    let updateFavoriteUseCase = UpdateExchangeRateFavoriteUseCase(repository: exchangeRateRepository)
    let getUserViewStateUseCase = GetUserViewStateUseCase(repository: userViewStateRepository)
    let updateUserViewStateUseCase = UpdateUserViewStateUseCase(repository: userViewStateRepository)
    let getPersistedExchangeRateUseCase = GetPersistedExchangeRateUseCase(repository: exchangeRateRepository)

    let viewModel = ExchangeRateViewModel(
      fetchExchangeRatesUseCase: fetchExchangeRatesUseCase,
      getCountryNameUseCase: getCountryNameUseCase,
      updateFavoriteUseCase: updateFavoriteUseCase
    )
    let exchangeRateViewController = ExchangeRateViewController(
      viewModel: viewModel,
      updateUserViewStateUseCase: updateUserViewStateUseCase
    )

    var rootViewControllers: [UIViewController] = [exchangeRateViewController]

    let lastState: AppViewState?
    do {
      lastState = try getUserViewStateUseCase.execute()
    } catch {
      print("[UserViewState] 불러오기 실패: \(error.localizedDescription)")
      lastState = nil
    }

    if case .currencyConverter(let currencyCode) = lastState?.screen {
      do {
        if let exchangeRate = try getPersistedExchangeRateUseCase.execute(currencyCode: currencyCode) {
          let countryName = getCountryNameUseCase.execute(currencyCode: currencyCode) ?? "-"
          let converterViewModel = CurrencyConverterViewModel(
            exchangeRate: exchangeRate,
            countryName: countryName
          )
          let converterViewController = CurrencyConverterViewController(
            viewModel: converterViewModel,
            updateUserViewStateUseCase: updateUserViewStateUseCase
          )
          rootViewControllers.append(converterViewController)
        } else {
          print("[UserViewState] 저장된 환율을 찾을 수 없어 리스트 화면으로 시작합니다.")
        }
      } catch {
        print("[UserViewState] 환율 복원 실패: \(error.localizedDescription)")
      }
    }

    let navigationController = UINavigationController()
    navigationController.viewControllers = rootViewControllers

    // UIWindow 설정
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    return true
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "CurrencyConverter")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

}
