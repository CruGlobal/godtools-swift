//
//  ArticlesView.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ArticlesView: UIViewController {
    
    private let viewModel: ArticlesViewModelType
           
    @IBOutlet weak private var errorMessageView: ArticlesErrorMessageView!
    @IBOutlet weak private var articlesTableView: UITableView!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    
    required init(viewModel: ArticlesViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ArticlesView.self), bundle: nil)
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
    }
    
    private func setupLayout() {
        
        articlesTableView.register(
            UINib(nibName: ArticleCell.nibName, bundle: nil),
            forCellReuseIdentifier: ArticleCell.reuseIdentifier
        )
        articlesTableView.separatorStyle = .none
        articlesTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setupBinding() {

        viewModel.navTitle.addObserver(self) { [weak self] (navTitle: String) in
            self?.title = navTitle
        }
        
        viewModel.articleAemImportData.addObserver(self) { [weak self] (articleAemImportData: [ArticleAemImportData]) in
        
            self?.articlesTableView.reloadData()
            
            if articleAemImportData.isEmpty {
                self?.articlesTableView.alpha = 0
            }
            else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                    self?.articlesTableView.alpha = 1
                }, completion: nil)
            }
        }
        
        viewModel.isLoading.addObserver(self) { [weak self] (isLoading: Bool) in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
        
        viewModel.errorMessage.addObserver(self) { [weak self] (errorMessage: ArticlesErrorMessage) in
            
            guard let viewModel = self?.viewModel else {
                return
            }
            
            if errorMessage.hidesErrorMessage {
                self?.errorMessageView.animateHidden(hidden: true, animated: errorMessage.shouldAnimate)
            }
            else {
                
                self?.errorMessageView.configure(
                    viewModel: ArticlesErrorMessageViewModel(localizationServices: viewModel.localizationServices, message: errorMessage.message),
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
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ArticlesView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articleAemImportData.value.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let articleAemImportData: ArticleAemImportData = viewModel.articleAemImportData.value[indexPath.row]
        viewModel.articleTapped(articleAemImportData: articleAemImportData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ArticleCell = articlesTableView.dequeueReusableCell(
            withIdentifier: ArticleCell.reuseIdentifier,
            for: indexPath) as! ArticleCell
        
        let articleAemImportData: ArticleAemImportData = viewModel.articleAemImportData.value[indexPath.row]
        
        let cellViewModel = ArticleCellViewModel(
            articleAemImportData: articleAemImportData
        )
        
        cell.configure(viewModel: cellViewModel)
        
        cell.selectionStyle = .none

        return cell
    }
}

// MARK: - ArticlesErrorMessageViewDelegate

extension ArticlesView: ArticlesErrorMessageViewDelegate {
    func articlesErrorMessageViewDownloadArticlesButtonTapped(articlesErrorMessageView: ArticlesErrorMessageView) {
        viewModel.downloadArticlesTapped()
    }
}
