//
//  ArticleCategoriesView.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ArticleCategoriesView: UIViewController {
    
    private let viewModel: ArticleCategoriesViewModelType
       
    private var refreshArticlesControl: UIRefreshControl = UIRefreshControl()
    
    @IBOutlet weak private var articlesTableView: UITableView!
    
    required init(viewModel: ArticleCategoriesViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ArticleCategoriesView.self), bundle: nil)
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
        
        setupLayout()
        setupBinding()
        
        addDefaultNavBackItem()
        
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        
        refreshArticlesControl.addTarget(
            self,
            action: #selector(handleRefreshArticleCategoriesControl),
            for: .valueChanged
        )
    }
    
    private func setupLayout() {
        
        articlesTableView.register(
            UINib(nibName: ArticleCategoryCell.nibName, bundle: nil),
            forCellReuseIdentifier: ArticleCategoryCell.reuseIdentifier
        )
        articlesTableView.separatorStyle = .none
        let articleAspectRatio: CGSize = CGSize(width: 15, height: 8)
        articlesTableView.rowHeight = floor(UIScreen.main.bounds.size.width / articleAspectRatio.width * articleAspectRatio.height)
        
        if #available(iOS 10.0, *) {
            articlesTableView.refreshControl = refreshArticlesControl
        } else {
            articlesTableView.addSubview(refreshArticlesControl)
        }
    }
    
    private func setupBinding() {

        viewModel.categories.addObserver(self) { [weak self] (categories: [ArticleCategory]) in
            self?.refreshArticlesControl.endRefreshing()
            self?.articlesTableView.reloadData()
        }
        
        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
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
        return viewModel.categories.value.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let category: ArticleCategory = viewModel.categories.value[indexPath.row]
        viewModel.articleTapped(category: category)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ArticleCategoryCell = articlesTableView.dequeueReusableCell(
            withIdentifier: ArticleCategoryCell.reuseIdentifier,
            for: indexPath) as! ArticleCategoryCell
        
        let category: ArticleCategory = viewModel.categories.value[indexPath.row]
        
        let cellViewModel = ArticleCategoryCellViewModel(
            category: category,
            cache: viewModel.resourceLanguageTranslationFilesCache
        )
        cell.configure(viewModel: cellViewModel)
 
        cell.selectionStyle = .none
        cell.backgroundColor = .lightGray
        
        return cell
    }
}
