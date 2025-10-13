//
//  CurrencyConverterViewController.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/1/25.
//

import UIKit
import SnapKit

class CurrencyConverterViewController: UIViewController {
  private let viewModel: CurrencyConverterViewModel
  private var currentState: CurrencyConverterViewModel.State
  private let updateUserViewStateUseCase: UpdateUserViewStateUseCaseProtocol

  private let currencyLabel: UILabel = {
    let label = UILabel()
    label.text = "Currency"
    label.font = .systemFont(ofSize: 24, weight: .bold)
    return label
  }()

  private let countryLabel: UILabel = {
    let label = UILabel()
    label.text = "Country"
    label.font = .systemFont(ofSize: 16)
    label.textColor = .secondaryText
    return label
  }()

  private let labelStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.alignment = .center
    return stackView
  }()

  private let amountTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "달러(USD)를 입력하세요"
    textField.borderStyle = .roundedRect
    textField.keyboardType = .decimalPad
    textField.textAlignment = .center
    return textField
  }()

  private let convertButton: UIButton = {
    let button = UIButton()
    button.setTitle("환율 계산", for: .normal)
    button.backgroundColor = .button
    button.tintColor = .white
    button.layer.cornerRadius = 8
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    return button
  }()

  private let resultLabel: UILabel = {
    let label = UILabel()
    label.text = "계산 결과가 여기에 표시됩니다"
    label.font = .systemFont(ofSize: 20, weight: .medium)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  init(
    viewModel: CurrencyConverterViewModel,
    updateUserViewStateUseCase: UpdateUserViewStateUseCaseProtocol
  ) {
    self.viewModel = viewModel
    self.currentState = viewModel.state
    self.updateUserViewStateUseCase = updateUserViewStateUseCase
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "환율 계산기"
    configureUI()
    convertButton.addTarget(self, action: #selector(convertButtonTapped), for: .touchUpInside)
    amountTextField.addTarget(self, action: #selector(amountTextFieldChanged(_:)), for: .editingChanged)
    amountTextField.delegate = self
    bindViewModel()

    viewModel.action?(.appear)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateLastSeenScreen()
  }

  private func configureUI() {
    view.backgroundColor = .background
    [
      labelStackView,
      amountTextField,
      convertButton,
      resultLabel
    ].forEach { view.addSubview($0) }

    [
      currencyLabel,
      countryLabel
    ].forEach { labelStackView.addArrangedSubview($0) }

    labelStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
      $0.leading.trailing.equalToSuperview().inset(24)
    }

    amountTextField.snp.makeConstraints {
      $0.top.equalTo(labelStackView.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(44)
    }

    convertButton.snp.makeConstraints {
      $0.top.equalTo(amountTextField.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.height.equalTo(44)
    }

    resultLabel.snp.makeConstraints {
      $0.top.equalTo(convertButton.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview().inset(24)
    }
  }

  @objc private func convertButtonTapped() {
    viewModel.action?(.convert)
  }

  @objc private func amountTextFieldChanged(_ sender: UITextField) {
    viewModel.action?(.amountChanged(sender.text ?? ""))
  }

  private func bindViewModel() {
    apply(state: viewModel.state)

    viewModel.stateDidChange = { [weak self] state in
      self?.apply(state: state)
    }
  }

  private func apply(state: CurrencyConverterViewModel.State) {
    currentState = state

    currencyLabel.text = state.currencyCode
    countryLabel.text = state.countryName

    if amountTextField.text != state.amountText {
      amountTextField.text = state.amountText
    }

    resultLabel.text = state.resultText

    guard let message = state.errorMessage else { return }
    presentErrorAlert(message: message)
  }

  private func presentErrorAlert(message: String) {
    let alert = UIAlertController(title: "입력 오류", message: message, preferredStyle: .alert)
    alert.addAction(
      UIAlertAction(title: "확인", style: .default) { [weak self] _ in
        self?.viewModel.action?(.dismissError)
      }
    )
    present(alert, animated: true)
  }

  private func updateLastSeenScreen() {
    do {
      try updateUserViewStateUseCase.execute(screen: .currencyConverter(currencyCode: currentState.currencyCode))
    } catch {
      print("[UserViewState] 업데이트 실패 - 계산기 화면: \(error.localizedDescription)")
    }
  }
}

extension CurrencyConverterViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
