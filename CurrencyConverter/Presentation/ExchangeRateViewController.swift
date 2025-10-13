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
  private var currentState: ExchangeRateViewModel.State
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let updateUserViewStateUseCase: UpdateUserViewStateUseCaseProtocol
  private lazy var refreshControl: UIRefreshControl = {
    let control = UIRefreshControl()
    control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    return control
  }()

  private let emptyResultLabel: UILabel = {
    let label = UILabel()
    label.text = "검색 결과 없습니다."
    label.textColor = .secondaryText
    label.textAlignment = .center
    return label
  }()

  private let searchBar: UISearchBar = {
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
  
  init(
    viewModel: ExchangeRateViewModel,
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
    navigationItem.title = "환율 정보"
    configureUI()
    searchBar.delegate = self
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
    setupActivityIndicator()
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

    tableView.refreshControl = refreshControl
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
    apply(state: viewModel.state)

    viewModel.stateDidChange = { [weak self] state in
      self?.apply(state: state)
    }
  }

  private func apply(state: ExchangeRateViewModel.State) {
    currentState = state

    if state.isLoading && !refreshControl.isRefreshing {
      activityIndicator.startAnimating()
    } else {
      activityIndicator.stopAnimating()
    }

    if !state.isLoading {
      refreshControl.endRefreshing()
    }

    tableView.reloadData()
    updateEmptyState()

    guard let message = state.errorMessage else { return }
    presentErrorAlert(message: message)
  }

  private func presentErrorAlert(message: String) {
    let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
    alert.addAction(
      UIAlertAction(title: "확인", style: .default) { [weak self] _ in
        self?.viewModel.action?(.dismissError)
      }
    )
    present(alert, animated: true)
  }

  private func updateEmptyState() {
    let shouldShowEmptyState = !currentState.searchQuery.isEmpty && currentState.exchangeRates.isEmpty
    tableView.backgroundView = shouldShowEmptyState ? emptyResultLabel : nil
  }

  private func updateLastSeenScreen() {
    do {
      try updateUserViewStateUseCase.execute(screen: .exchangeRateList)
    } catch {
      print("[UserViewState] 업데이트 실패 - 환율 리스트: \(error.localizedDescription)")
    }
  }

  @objc
  private func handleRefresh() {
    viewModel.action?(.refresh)
  }
}

extension ExchangeRateViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard currentState.exchangeRates.indices.contains(indexPath.row) else { return }

    let row = currentState.exchangeRates[indexPath.row]
    let converterVM = CurrencyConverterViewModel(
      exchangeRate: row.exchangeRate,
      countryName: row.countryName ?? "-"
    )

    let converterVC = CurrencyConverterViewController(
      viewModel: converterVM,
      updateUserViewStateUseCase: updateUserViewStateUseCase
    )

    navigationController?.pushViewController(converterVC, animated: true)
  }
}

extension ExchangeRateViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    currentState.exchangeRates.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeRateCellView.id) as? ExchangeRateCellView,
      currentState.exchangeRates.indices.contains(indexPath.row)
    else { return UITableViewCell() }

    let row = currentState.exchangeRates[indexPath.row]
    cell.configureCell(exchangeRate: row.exchangeRate, countryName: row.countryName)
    cell.onToggleFavorite = { [weak self] currencyCode, isFavorite in
      self?.viewModel.action?(.toggleFavorite(currencyCode: currencyCode, isFavorite: isFavorite))
    }
    return cell
  }
}

extension ExchangeRateViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.action?(.search(searchText))
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}
