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
           
    @IBOutlet weak private var errorMessageView: ArticlesErrorMessageView!
    @IBOutlet weak private var categoriesTableView: UITableView!
    @IBOutlet weak private var loadingMessageLabel: UILabel!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    
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
        
        if #available(iOS 10.0, *) {
            categoriesTableView.refreshControl = refreshArticlesControl
        } else {
            categoriesTableView.addSubview(refreshArticlesControl)
        }
    }
    
    private func setupBinding() {

        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.categories.addObserver(self) { [weak self] (categories: [ArticleCategory]) in
            
            self?.refreshArticlesControl.endRefreshing()
            self?.categoriesTableView.reloadData()
            
            if categories.isEmpty {
                self?.categoriesTableView.alpha = 0
            }
            else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                    self?.categoriesTableView.alpha = 1
                }, completion: nil)
            }
        }
        
        viewModel.loadingMessage.addObserver(self) { [weak self] (loadingMessage: String) in
            self?.loadingMessageLabel.text = loadingMessage
        }
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
        
        viewModel.errorMessage.addObserver(self) { [weak self] (errorMessage: ArticlesErrorMessage) in
                
            if errorMessage.hidesErrorMessage {
                self?.errorMessageView.animateHidden(hidden: true, animated: errorMessage.shouldAnimate)
            }
            else {
                
                self?.errorMessageView.configure(
                    viewModel: ArticlesErrorMessageViewModel(message: errorMessage.message),
                    delegate: self
                )
                self?.errorMessageView.animateHidden(hidden: false, animated: errorMessage.shouldAnimate)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
    
    @objc func handleDownloadArticles(button: UIButton) {
        viewModel.downloadArticlesTapped()
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
        
        let cell: ArticleCategoryCell = categoriesTableView.dequeueReusableCell(
            withIdentifier: ArticleCategoryCell.reuseIdentifier,
            for: indexPath) as! ArticleCategoryCell
        
        let category: ArticleCategory = viewModel.categories.value[indexPath.row]
        
        let cellViewModel = ArticleCategoryCellViewModel(
            category: category,
            godToolsResource: viewModel.godToolsResource,
            resourcesFileCache: viewModel.resourceLatestTranslationServices.fileCache
        )
        cell.configure(viewModel: cellViewModel)
 
        cell.selectionStyle = .none
        cell.backgroundColor = .lightGray
        
        return cell
    }
}

// MARK: - ArticlesErrorMessageViewDelegate

extension ArticleCategoriesView: ArticlesErrorMessageViewDelegate {
    func articlesErrorMessageViewDownloadArticlesButtonTapped() {
        viewModel.downloadArticlesTapped()
    }
}
