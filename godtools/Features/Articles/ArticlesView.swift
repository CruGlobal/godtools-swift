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
           
    @IBOutlet weak private var articlesTableView: UITableView!
    
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
            UINib(nibName: ArticleCategoryCell.nibName, bundle: nil),
            forCellReuseIdentifier: ArticleCategoryCell.reuseIdentifier
        )
        articlesTableView.separatorStyle = .none
        articlesTableView.rowHeight = 70
    }
    
    private func setupBinding() {

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
        return 0//viewModel.articles.value.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let category: ArticleCategory = viewModel.categories.value[indexPath.row]
        //viewModel.articleTapped(category: category)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
//        let cell: ArticleCategoryCell = categoriesTableView.dequeueReusableCell(
//            withIdentifier: ArticleCategoryCell.reuseIdentifier,
//            for: indexPath) as! ArticleCategoryCell
//
//        let category: ArticleCategory = viewModel.categories.value[indexPath.row]
//
//        let cellViewModel = ArticleCategoryCellViewModel(
//            category: category,
//            cache: viewModel.resourceLanguageTranslationFilesCache
//        )
//        cell.configure(viewModel: cellViewModel)
//
//        cell.selectionStyle = .none
//        cell.backgroundColor = .lightGray
//
//        return cell
    }
}
