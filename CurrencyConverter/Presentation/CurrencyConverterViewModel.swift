//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/1/25.
//

import Foundation

@MainActor
final class CurrencyConverterViewModel: ViewModelProtocol {

  enum Action {
    case appear
    case amountChanged(String)
    case convert
    case dismissError
  }

  struct State {
    let currencyCode: String
    let countryName: String
    var amountText: String
    var resultText: String
    var isConvertButtonEnabled: Bool
    var errorMessage: String?

    static func initial(currencyCode: String, countryName: String) -> State {
      State(
        currencyCode: currencyCode,
        countryName: countryName,
        amountText: "",
        resultText: "계산 결과가 여기에 표시됩니다",
        isConvertButtonEnabled: false,
        errorMessage: nil
      )
    }
  }

  var action: ((Action) -> Void)? { handleAction }

  private(set) var state: State {
    didSet { stateDidChange?(state) }
  }

  var stateDidChange: ((State) -> Void)? {
    didSet { stateDidChange?(state) }
  }

  private lazy var handleAction: (Action) -> Void = { [weak self] action in
    self?.handle(action)
  }

  private let exchangeRate: ExchangeRate
  private let countryName: String

  init(exchangeRate: ExchangeRate, countryName: String) {
    self.exchangeRate = exchangeRate
    self.countryName = countryName
    self.state = .initial(currencyCode: exchangeRate.currencyCode, countryName: countryName)
  }

  private func handle(_ action: Action) {
    switch action {
    case .appear:
      setState { $0 = .initial(currencyCode: exchangeRate.currencyCode, countryName: countryName) }
    case .amountChanged(let text):
      updateAmount(text)
    case .convert:
      convertAmount()
    case .dismissError:
      setState { $0.errorMessage = nil }
    }
  }

  private func updateAmount(_ text: String) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    let isValid = parsedAmount(from: trimmed) != nil

    setState {
      $0.amountText = trimmed
      $0.isConvertButtonEnabled = isValid
      if trimmed.isEmpty {
        $0.resultText = "계산 결과가 여기에 표시됩니다"
      }
    }
  }

  private func convertAmount() {
    guard let amount = parsedAmount(from: state.amountText) else {
      setState { $0.errorMessage = "금액을 정확히 입력하세요." }
      return
    }

    let converted = amount * exchangeRate.rate
    let result = String(format: "$%.2f -> %.2f %@", amount, converted, state.currencyCode)

    setState {
      $0.resultText = result
      $0.errorMessage = nil
    }
  }

  private func parsedAmount(from text: String) -> Double? {
    guard !text.isEmpty else { return nil }
    return Double(text)
  }

  private func setState(_ mutation: (inout State) -> Void) {
    var next = state
    mutation(&next)
    state = next
  }
}
