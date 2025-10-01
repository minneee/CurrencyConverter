//
//  ExchangeRateViewController.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import UIKit
import SnapKit

class ExchangeRateViewController: UIViewController {
  private let viewModel: ExchangeRateViewModel
  private let activityIndicator = UIActivityIndicatorView(style: .large)

  private lazy var emptyResultLabel: UILabel = {
    let label = UILabel()
    label.text = "검색 결과 없습니다."
    label.textColor = .secondaryText
    label.textAlignment = .center
    return label
  }()

  private var searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "통화 검색"
    searchBar.searchBarStyle = .minimal
    return searchBar
  }()

  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .background
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ExchangeRateCellView.self, forCellReuseIdentifier: ExchangeRateCellView.id)
    return tableView
  }()
  
  init(viewModel: ExchangeRateViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "환율 정보"
    configureUI()
    searchBar.delegate = self
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
    setupActivityIndicator()
    bindViewModel()

    viewModel.loadExchangeRates()
  }
  
  private func configureUI() {
    view.backgroundColor = .background
    [
      searchBar,
      tableView
    ].forEach { view.addSubview($0) }

    searchBar.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview()
    }

    tableView.snp.makeConstraints {
      $0.top.equalTo(searchBar.snp.bottom)
      $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  private func setupActivityIndicator() {
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    view.bringSubviewToFront(activityIndicator)
  }
  
  private func bindViewModel() {
    // 데이터가 갱신되면 테이블뷰 리로드
    viewModel.onUpdate = { [weak self] in
      self?.tableView.reloadData()
      self?.updateEmptyState()
    }
    
    // 로딩 상태 처리
    viewModel.onLoadingStateChange = { [weak self] isLoading in
      isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
    }
    
    // 에러 발생 시 Alert 띄우기
    viewModel.onError = { [weak self] message in
      let alert = UIAlertController(title: "오류", message: "데이터를 불러올 수 없습니다", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "확인", style: .default))
      self?.present(alert, animated: true)
    }
  }

  private func updateEmptyState() {
    let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let shouldShowEmptyState = !query.isEmpty && viewModel.exchangeRates.isEmpty
    tableView.backgroundView = shouldShowEmptyState ? emptyResultLabel : nil
  }
}

extension ExchangeRateViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let selectedRate = viewModel.exchangeRates[indexPath.row]
    let selectedCountry = viewModel.countryName(currencyCode: selectedRate.currencyCode) ?? "-"
    let converterVM = CurrencyConverterViewModel(exchangeRate: selectedRate, countryName: selectedCountry)

    self.navigationController?.pushViewController(CurrencyConverterViewController(viewModel: converterVM), animated: true)
  }
}

extension ExchangeRateViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.exchangeRates.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeRateCellView.id) as? ExchangeRateCellView else { return UITableViewCell() }
    let exchangeRate = viewModel.exchangeRates[indexPath.row]
    let countryName = viewModel.countryName(currencyCode: exchangeRate.currencyCode)
    cell.configureCell(exchangeRate: exchangeRate, countryName: countryName)
    return cell
  }
}

extension ExchangeRateViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.filterExchangeRates(with: searchText)
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}
