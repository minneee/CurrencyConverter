//
//  ExchangeRateRepository.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import Alamofire
import Foundation

/// Repository 구현체 (네트워크 + 로컬 캐시 관리)
/// - Core Data에 저장된 데이터가 있으면 우선 반환합니다.
/// - 없다면 API를 호출하고, 성공 시 Core Data에 갱신 후 반환합니다.
final class ExchangeRateRepository: ExchangeRateRepositoryProtocol {
  private let url = "https://open.er-api.com/v6/latest/USD"
  private let localStorage: CoreDataExchangeRateStorage
  private let session: Session
  private let calendar: Calendar

  init(
    localStorage: CoreDataExchangeRateStorage,
    session: Session = AF,
    calendar: Calendar = .current
  ) {
    self.localStorage = localStorage
    self.session = session
    self.calendar = calendar
  }

  func fetchExchangeRates() async throws -> [ExchangeRate] {
    let today = calendar.startOfDay(for: Date())
    let todayString = ISO8601DateFormatter().string(from: today)

    do {
      let cached = try localStorage.fetchRates(for: today)
      if !cached.isEmpty {
        print("[환율저장소] 로컬 캐시 - 날짜: \(todayString), 건수: \(cached.count)건")
        return sortExchangeRates(cached.map(makeDomainModel))
      }
      print("[환율저장소] 로컬 캐시 없음 - 날짜: \(todayString)")
    } catch {
      print("[환율저장소] 로컬 캐시 조회 실패 - 오류: \(error.localizedDescription)")
    }

    let response = try await requestLatestRates()
    print("[환율저장소] 네트워크 수신 완료 - 기준통화: \(response.base_code), 건수: \(response.rates.count)건")

    do {
      try localStorage.upsert(
        baseCode: response.base_code,
        rates: response.rates,
        timestamp: today
      )

      let refreshed = try localStorage.fetchRates(for: today)
      if !refreshed.isEmpty {
        print("[환율저장소] 로컬 캐시 갱신 후 반환 - 날짜: \(todayString), 건수: \(refreshed.count)건")
        return sortExchangeRates(refreshed.map(makeDomainModel))
      }
      print("[환율저장소] 로컬 캐시 갱신 결과 없음 - 네트워크 데이터 사용")
    } catch {
      print("[환율저장소] 로컬 캐시 갱신 실패 - 오류: \(error.localizedDescription), 네트워크 데이터 사용")
    }

    let remoteRates = response.rates
      .map { ExchangeRate(currencyCode: $0.key, rate: $0.value, isFavorite: false) }
    print("[환율저장소] 네트워크 데이터 반환 - 날짜: \(todayString), 건수: \(remoteRates.count)건")
    return sortExchangeRates(remoteRates)
  }

  func fetchPersistedExchangeRate(currencyCode: String) throws -> ExchangeRate? {
    guard let persisted = try localStorage.fetchRate(for: currencyCode) else { return nil }
    return makeDomainModel(from: persisted)
  }

  private func requestLatestRates() async throws -> ExchangeRateResponseDTO {
    let request = session.request(url, method: .get).validate()
    let dataTask = request.serializingData()
    let data = try await dataTask.value
    return try JSONDecoder().decode(ExchangeRateResponseDTO.self, from: data)
  }

  private func makeDomainModel(from persisted: PersistedExchangeRate) -> ExchangeRate {
    ExchangeRate(
      currencyCode: persisted.currencyCode,
      rate: persisted.rate,
      previousRate: persisted.previousRate,
      isFavorite: persisted.isFavorite
    )
  }

  private func sortExchangeRates(_ rates: [ExchangeRate]) -> [ExchangeRate] {
    rates.sorted { lhs, rhs in
      if lhs.isFavorite != rhs.isFavorite {
        return lhs.isFavorite && !rhs.isFavorite
      }
      return lhs.currencyCode < rhs.currencyCode
    }
  }

  func updateFavorite(currencyCode: String, isFavorite: Bool) async throws {
    try await localStorage.updateFavorite(for: currencyCode, isFavorite: isFavorite)
  }
}
