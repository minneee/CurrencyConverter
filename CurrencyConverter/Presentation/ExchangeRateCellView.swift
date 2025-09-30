//
//  ExchangeRateCellView.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import UIKit
import SnapKit

final class ExchangeRateCellView: UITableViewCell {
  static let id = "ExchangeRateCellView"
  
  let currencyNameLabel: UILabel = {
    let label = UILabel()
    label.text = "KRW"
    label.textColor = .text
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  let countryNameLabel: UILabel = {
    let label = UILabel()
    label.text = "대한민국"
    label.textColor = .secondaryText
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()

  let labelStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    return stackView
  }()

  let exchangeRateLabel: UILabel = {
    let label = UILabel()
    label.text = "0"
    label.textColor = .text
    label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    return label
  }()
  
  let spacerView: UIView = {
    let view = UIView()
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    return view
  }()
  
  let exchangeRateStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    return stackView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.backgroundColor = .background
    [
      exchangeRateStackView
    ].forEach { contentView.addSubview($0) }
    
    [
      labelStackView,
      spacerView,
      exchangeRateLabel
    ].forEach { exchangeRateStackView.addArrangedSubview($0) }

    [
      currencyNameLabel,
      countryNameLabel
    ].forEach { labelStackView.addArrangedSubview($0) }

    exchangeRateStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(12)
      $0.leading.trailing.equalToSuperview().inset(30)
    }
  }
  
  func configureCell(exchangeRate: ExchangeRate, countryName: String?) {
    if let countryName = countryName, !countryName.isEmpty {
      countryNameLabel.text = countryName
    } else {
      countryNameLabel.text = "-"
    }
    currencyNameLabel.text = exchangeRate.currencyCode
    exchangeRateLabel.text = String(format: "%.4f", exchangeRate.rate)
  }
}
