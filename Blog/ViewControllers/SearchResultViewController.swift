//
//  SearchResultViewController.swift
//  Blog
//
//  Created by Amini on 26/11/22.
//

import UIKit

protocol SelectedResultProtocol {
    func didSelectResult(post: Post)
}

class SearchResultViewController: UIViewController {
    
    
    private var results: [Post] = []
    
    var tableview: UITableView! = nil
    var delegate: SelectedResultProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureViews()
    }
    
    private func configureViews() {
        tableview = UITableView(frame: view.bounds)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
        view.addSubview(tableview)
    }
    
    public func update(with results: [Post]) {
        self.results = results
        tableview.reloadData()
    }
}

extension SearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableview.dequeueReusableCell(withIdentifier: SearchResultCell.identifier, for: indexPath) as? SearchResultCell else { return UITableViewCell() }
        cell.configure(post: results[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
    
}

extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectResult(post: results[indexPath.row])
    }
}
