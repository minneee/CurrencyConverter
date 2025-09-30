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
    configureUI()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
    setupActivityIndicator()
    bindViewModel()
    
    viewModel.loadExchangeRates()
  }
  
  private func configureUI() {
    view.backgroundColor = .background
    [
      tableView
    ].forEach { view.addSubview($0) }
    
    tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
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
    }
    
    // 로딩 상태 처리
    viewModel.onLoadingStateChange = { [weak self] isLoading in
      isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
    }
    
    // 에러 발생 시 Alert 띄우기
    viewModel.onError = { [weak self] message in
      let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "확인", style: .default))
      self?.present(alert, animated: true)
    }
  }
}

extension ExchangeRateViewController: UITableViewDelegate {
  
}
extension ExchangeRateViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.exchangeRates.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeRateCellView.id) as? ExchangeRateCellView else { return UITableViewCell() }
    cell.configureCell(exchangeRate: viewModel.exchangeRates[indexPath.row])
    return cell
  }
}
