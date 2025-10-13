//
//  ExchangeRateRepository.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import Foundation
import Alamofire

/// Repository 구현체 (실제 네트워크 호출 담당)
/// - Alamofire를 사용하여 API를 호출합니다.
/// - API 응답(Entity)을 Domain 모델(ExchangeRate)로 변환합니다.
final class ExchangeRateRepository: ExchangeRateRepositoryProtocol {
  private let url = "https://open.er-api.com/v6/latest/USD"

  // 환율 정보를 비동기적으로 가져오는 함수입니다.
  func fetchExchangeRates() async throws -> [ExchangeRate] {
    let request = AF.request(url, method: .get)
    // 서버 응답 코드가 200~299(성공 범위)에 있는지 자동으로 확인합니다.
    // 만약 성공 범위가 아니면 에러를 발생시킵니다.
      .validate()

    // 위에서 설정한 요청을 'Data' 타입으로 비동기 처리할 준비를 합니다.
    let dataTask = request.serializingData()

    // 실제로 네트워크 요청을 보내는 부분입니다.
    // 성공하면 서버가 보낸 데이터를 'data' 상수에 저장합니다.
    // 실패하면(validate 실패 등) 에러를 던집니다.
    let data = try await dataTask.value

    // JSONDecoder를 사용해 받아온 데이터(data)를
    // Data에서 정의한 'ExchangeRateResponse' 구조체 형태로 디코딩합니다.
    let response = try JSONDecoder().decode(ExchangeRateResponseDTO.self, from: data)

    // 디코딩된 'ExchangeRateResponse' 객체를 앱에서 사용할
    // 도메인 모델('ExchangeRate'의 배열)로 변환하여 반환합니다.
    return response.rates
      .map { ExchangeRate(currencyCode: $0.key, rate: $0.value) }
      .sorted(by: { $0.currencyCode < $1.currencyCode })
  }
}
