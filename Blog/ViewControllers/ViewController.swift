//
//  ViewController.swift
//  Blog
//
//  Created by Amini on 20/11/22.
//

import UIKit

class ViewController: UIViewController, UISearchResultsUpdating, SelectedResultProtocol {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? SearchResultViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        BlogAPI.share.getBlogPosts(search: query) { (posts:Posts?, error:Error?) in
            if error == nil {
                guard let postData: [Post] = posts?.posts else { return }
                resultsController.delegate = self
                resultsController.update(with: postData)
            }
        }
        
    }
    
    func didSelectResult(post: Post) {
        let contentVC = ContentViewController()
        contentVC.configure(post: post)
        self.navigationController?.pushViewController(contentVC, animated: true)
        searchController.isActive = false
    }
    enum LayoutType {
        case list, grid
        
        var switchImage: String {
            switch self {
            case .list: return "rectangle.grid.1x2.fill"
            case .grid: return "rectangle.grid.2x2.fill"
            }
        }
    }
    
    var collectionView: UICollectionView! = nil
    var barbuttonItem: UIBarButtonItem! = nil
    
    var layoutType = LayoutType.list
    
    var posts: [Post] = []
    
    let searchController = UISearchController(searchResultsController: SearchResultViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        BlogAPI.share.getAllPost { [self] (posts: Posts?, error: Error?) in
            guard error == nil, posts != nil else { return }
            self.posts = posts!.posts
            switchView()
        }
                
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        
        barbuttonItem = UIBarButtonItem(image: UIImage(systemName: layoutType.switchImage), style: .done, target: self, action: #selector(switchView))
        barbuttonItem.tintColor = .black
        navigationItem.rightBarButtonItem = barbuttonItem
        configureViews()
    }
    
    @objc private func switchView() {
        
        UIView.animate(withDuration: 0.5, delay: 0.1) { [self] in
            layoutType = self.layoutType == .list ? .grid : .list
            
            barbuttonItem = UIBarButtonItem(image: UIImage(systemName: layoutType.switchImage), style: .done, target: self, action: #selector(switchView))
            barbuttonItem.tintColor = .black
            navigationItem.rightBarButtonItem = barbuttonItem
            navigationItem.hidesSearchBarWhenScrolling = false
            collectionView.collectionViewLayout = createLayout()
            collectionView.reloadData()
            scrollToTop()
        }
    }
    
    private func scrollToTop() {
         DispatchQueue.main.async {
             let indexPath = IndexPath(row: 0, section: 0)
             self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
//             self.collectionView.scrollRectToVisible(CGRect(x: 0, y: -30, width: UIScreen.main.bounds.width, height: 100), animated: true)
             
         }
    }

    
    private func configureViews() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifier)
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: GridCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
        
    private func createLayout() -> UICollectionViewLayout {
        
        let itemsize = layoutType == .list ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)) : NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemsize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        let groupsize = layoutType == .list ? NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(144)) : NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
                
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.layoutType {
        case .list:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.identifier, for: indexPath) as? ListCell else { return UICollectionViewCell() }
            cell.configure(post: posts[indexPath.row])
            return cell
        case .grid:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.identifier, for: indexPath) as? GridCell else { return UICollectionViewCell() }
            cell.configure(post: posts[indexPath.row])
            return cell
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let contentVC = ContentViewController()
        contentVC.configure(post: posts[indexPath.row])
        
        navigationController?.pushViewController(contentVC, animated: true)
    }
}

