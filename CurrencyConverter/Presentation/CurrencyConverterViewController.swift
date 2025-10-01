//
//  CurrencyConverterViewController.swift
//  CurrencyConverter
//
//  Created by 김민희 on 10/1/25.
//

import UIKit
import SnapKit

class CurrencyConverterViewController: UIViewController {

  let currencyLabel: UILabel = {
    let label = UILabel()
    label.text = "Currency"
    label.font = .systemFont(ofSize: 24, weight: .bold)
    return label
  }()

  let countryLabel: UILabel = {
    let label = UILabel()
    label.text = "Country"
    label.font = .systemFont(ofSize: 16)
    label.textColor = .secondaryText
    return label
  }()

  let labelStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.alignment = .center
    return stackView
  }()

  let amountTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "금액을 입력하세요"
    textField.borderStyle = .roundedRect
    textField.keyboardType = .decimalPad
    textField.textAlignment = .center
    return textField
  }()

  let convertButton: UIButton = {
    let button = UIButton()
    button.setTitle("환율 계산", for: .normal)
    button.backgroundColor = .button
    button.tintColor = .white
    button.layer.cornerRadius = 8
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    return button
  }()

  let resultLabel: UILabel = {
    let label = UILabel()
    label.text = "계산 결과가 여기에 표시됩니다"
    label.font = .systemFont(ofSize: 20, weight: .medium)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "환율 계산기"
    configureUI()
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
}
