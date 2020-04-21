//
//  ArticleToolViewController.swift
//  godtools
//
//  Created by Igor Ostriz on 13/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import UIKit

class ArticleToolViewController: BaseViewController {
    
    private let viewModel: ArticleCategoriesViewModelType
    
    var resource: DownloadedResource?
    var articleManager = ArticleManager()
    
    var primaryLanguage: Language?
    
    var refreshControl = UIRefreshControl()
        
    override var screenTitle: String {
        get {
            return resource?.name ?? super.screenTitle
        }
    }
    
    @IBOutlet weak private var tableView: UITableView!
    
    required init(viewModel: ArticleCategoriesViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "ArticleToolViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        self.removeObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        
        refreshControl.addTarget(self, action: #selector(downloadManifestData), for: .valueChanged)
        defineObservers()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
                
        if let primaryLanguage = LanguagesManager().loadPrimaryLanguageFromDisk() {
            self.primaryLanguage = primaryLanguage
        }
        else {
            primaryLanguage = LanguagesManager().loadFromDisk(code: "en")
        }
        
        getResourceData(forceDownload: false)
        
        addDefaultNavBackItem()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLayout() {
        
        tableView.register(
            UINib(nibName: ArticleCategoryCell.nibName, bundle: nil),
            forCellReuseIdentifier: ArticleCategoryCell.reuseIdentifier
        )
        let articleAspectRatio: CGSize = CGSize(width: 15, height: 8)
        tableView.rowHeight = floor(UIScreen.main.bounds.size.width / articleAspectRatio.width * articleAspectRatio.height)
    }
    
    func defineObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: .downloadPrimaryTranslationCompleteNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(articleProcessingDone), name: .articleProcessingCompleted, object: nil)
    }
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc private func reloadView() {
        assert(Thread.isMainThread, "Should process in main thread")
        
        tableView.reloadData()
    }
    
    
    @objc private func downloadManifestData() {
        getResourceData(forceDownload: true)
    }
    
    @objc private func articleProcessingDone() {
        assert(Thread.isMainThread, "Should process in main thread")
        
        refreshControl.endRefreshing()
        // reload data, but after a short delay to prevent ugly refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reloadView()
            
        }
    }
    
    func getResourceData(forceDownload: Bool) {
        
        if forceDownload && !Reachability.isConnectedToNetwork() {
            
            refreshControl.endRefreshing()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showNoInternetAlert()
            }
            
            return
        }
        
        let _ = self.articleManager.loadResource(resource: self.resource!, language: primaryLanguage!, forceDownload: forceDownload)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ArticleToolViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleManager.categories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = articleManager.categories[indexPath.row]
        presentArticlesList(category: category)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ArticleCategoryCell = tableView.dequeueReusableCell(
            withIdentifier: ArticleCategoryCell.reuseIdentifier,
            for: indexPath) as! ArticleCategoryCell
        
        let category: XMLArticleCategory = articleManager.categories[indexPath.row]
        
//        let cellViewModel = ArticleCellViewModel(
//            category: category,
//            articleManager: articleManager
//        )
//        cell.configure(viewModel: cellViewModel)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    
    func presentArticlesList(category: XMLArticleCategory?) {
        guard let category = category else {
            return
        }
        
        // TODO: put arguments in create()
        let vc = ArticleCategoryViewController.create()
        vc.articleManager = articleManager
        vc.category = category
        vc.articlesPath = articleManager.articlesPath
        vc.resource = resource
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
