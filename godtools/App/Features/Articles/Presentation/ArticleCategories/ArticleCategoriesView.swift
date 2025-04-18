//
//  ArticleCategoriesView.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ArticleCategoriesView: AppViewController {
    
    private let viewModel: ArticleCategoriesViewModel
    
    private var refreshArticlesControl: UIRefreshControl = UIRefreshControl()
           
    @IBOutlet weak private var categoriesTableView: UITableView!
    
    init(viewModel: ArticleCategoriesViewModel, navigationBar: AppNavigationBar?) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ArticleCategoriesView.self), bundle: nil, navigationBar: navigationBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        addScreenAccessibility(screenAccessibility: .articles)
        
        setupLayout()
        setupBinding()
                                
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        
        refreshArticlesControl.addTarget(
            self,
            action: #selector(handleRefreshArticleCategoriesControl),
            for: .valueChanged
        )
    }
    
    private func setupLayout() {
                
        // categoriesTableView
        categoriesTableView.register(
            UINib(nibName: ArticleCategoryCell.nibName, bundle: nil),
            forCellReuseIdentifier: ArticleCategoryCell.reuseIdentifier
        )
        categoriesTableView.separatorStyle = .none
        let cellAspectRatio: CGSize = CGSize(width: 15, height: 8)
        categoriesTableView.rowHeight = floor(UIScreen.main.bounds.size.width / cellAspectRatio.width * cellAspectRatio.height)
        
        categoriesTableView.refreshControl = refreshArticlesControl
    }
    
    private func setupBinding() {
        
        viewModel.numberOfCategories.addObserver(self) { [weak self] (numberOfCategories: Int) in
            
            self?.categoriesTableView.reloadData()
            
            if numberOfCategories == 0 {
                self?.categoriesTableView.alpha = 0
            }
            else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                    self?.categoriesTableView.alpha = 1
                }, completion: nil)
            }
        }
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            if !isLoading {
                self?.refreshArticlesControl.endRefreshing()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
    
    @objc func handleRefreshArticleCategoriesControl() {
        viewModel.refreshArticles()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ArticleCategoriesView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories.value
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.categoryTapped(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = categoriesTableView.dequeueReusableCell(
            withIdentifier: ArticleCategoryCell.reuseIdentifier,
            for: indexPath) as? ArticleCategoryCell else {
            
            assertionFailure("Failed to dequeue reusable cell with identifier :\(ArticleCategoryCell.reuseIdentifier)")
            
            return UITableViewCell()
        }
        
        let cellViewModel: ArticleCategoryCellViewModel = viewModel.categoryWillAppear(index: indexPath.row)
        
        cell.configure(viewModel: cellViewModel)
        
        return cell
    }
}
