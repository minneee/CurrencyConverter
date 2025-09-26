//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by 김민희 on 9/26/25.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .background
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ExchangeRateCellView.self, forCellReuseIdentifier: ExchangeRateCellView.id)
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
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
}

extension ViewController: UITableViewDelegate {
  
}
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    20
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeRateCellView.id) as? ExchangeRateCellView else { return UITableViewCell() }
    return cell
  }
}
