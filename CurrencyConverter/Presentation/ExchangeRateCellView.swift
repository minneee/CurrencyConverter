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
  
  private let currencyNameLabel: UILabel = {
    let label = UILabel()
    label.text = "KRW"
    label.textColor = .text
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    return label
  }()

  private let countryNameLabel: UILabel = {
    let label = UILabel()
    label.text = "대한민국"
    label.textColor = .secondaryText
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()

  private let labelStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    return stackView
  }()

  private let exchangeRateLabel: UILabel = {
    let label = UILabel()
    label.text = "0"
    label.textColor = .text
    label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    return label
  }()
  
  private let spacerView: UIView = {
    let view = UIView()
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    return view
  }()

  private let starToggleButton: UIButton = {
    let button = UIButton(type: .custom)
    button.tintColor = .systemYellow
    button.setImage(UIImage(systemName: "star"), for: .normal)
    button.setImage(UIImage(systemName: "star.fill"), for: .selected)
    button.backgroundColor = .clear
    return button
  }()

  var onToggleFavorite: ((String, Bool) -> Void)?
  private var currentExchangeRate: ExchangeRate?

  private let exchangeRateStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.spacing = 8
    return stackView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    onToggleFavorite = nil
    currentExchangeRate = nil
  }
  
  private func configureUI() {
    contentView.backgroundColor = .background
    [
      exchangeRateStackView
    ].forEach { contentView.addSubview($0) }
    
    [
      labelStackView,
      spacerView,
      exchangeRateLabel,
      starToggleButton
    ].forEach { exchangeRateStackView.addArrangedSubview($0) }

    [
      currencyNameLabel,
      countryNameLabel
    ].forEach { labelStackView.addArrangedSubview($0) }

    exchangeRateStackView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(12)
      $0.leading.trailing.equalToSuperview().inset(30)
    }

    starToggleButton.snp.makeConstraints {
      $0.width.height.equalTo(26)
    }

    starToggleButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
  }

  func configureCell(exchangeRate: ExchangeRate, countryName: String?) {
    currentExchangeRate = exchangeRate
    if let countryName = countryName, !countryName.isEmpty {
      countryNameLabel.text = countryName
    } else {
      countryNameLabel.text = "-"
    }
    currencyNameLabel.text = exchangeRate.currencyCode
    exchangeRateLabel.text = String(format: "%.4f", exchangeRate.rate)

    starToggleButton.isSelected = exchangeRate.isFavorite
  }

  @objc private func toggleFavorite() {
    starToggleButton.isSelected.toggle()
    guard let currencyCode = currentExchangeRate?.currencyCode else { return }
    onToggleFavorite?(currencyCode, starToggleButton.isSelected)
  }
}
