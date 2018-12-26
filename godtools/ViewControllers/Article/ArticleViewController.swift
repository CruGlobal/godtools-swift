//
//  ArticleViewController.swift
//  godtools
//
//  Created by Igor Ostriz on 13/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import UIKit


class ArticleViewController: BaseViewController {

    var resource: DownloadedResource?
    var articleManager = ArticleManager()
    
    var primaryLanguage: Language?
    var parallelLanguage: Language?
    var selectedLanguage: Language?
    var xmlPages: XMLArticlePages?
    var xmlPagesForPrimaryLang: XMLArticlePages?
    var xmlPagesForParallelLang: XMLArticlePages?
    var xmlCatgegoriesForPrimaryLang = [XMLArticleCategory]()
    var xmlCategoriesForParalelLang = [XMLArticleCategory]()
    
    var refreshControl = UIRefreshControl()

    var arrivedByUniversalLink = false
    var universalLinkLanguage: Language?

    override var screenTitle: String {
        get {
            return resource?.name ?? super.screenTitle
        }
    }
    
    static func create() -> ArticleViewController {
        let storyboard = UIStoryboard(name: Storyboard.articles, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "ArticleViewControllerID") as! ArticleViewController

//        return ArticleViewController(nibName: String(describing: ArticleViewController.self), bundle: nil)
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: String(describing: ArticleTableViewCell.self), bundle: nil), forCellReuseIdentifier: ArticleTableViewCell.cellID)
    }

    deinit {
        self.removeObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.addTarget(self, action: #selector(downloadManifestData), for: .valueChanged)
        defineObservers()

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        registerCells()
        loadLanguages()
        getResourceData(forceDownload: false)

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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showNoInternetAlert()
            }
            return
            
        }
        loadResourcesForLanguage(forceDownload: forceDownload)
        loadResourcesForParallelLanguage(forceDownload: forceDownload)
        usePrimaryLanguageResources()
    }
    
    
    
    // Mark Languages handlers
    
    private func loadLanguages() {
        guard let resource = resource else {
            return
        }
        
        let languagesManager = LanguagesManager()
        
        primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk()
        
        if resource.getTranslationForLanguage(primaryLanguage!) == nil {
            primaryLanguage = languagesManager.loadFromDisk(code: "en")
        }
        
        parallelLanguage = languagesManager.loadParallelLanguageFromDisk(arrivingFromUniversalLink: arrivedByUniversalLink)
    }

    func loadResourcesForLanguage(forceDownload: Bool) {
        guard let language = resolvePrimaryLanguage() else { return }
        guard let resource = resource else { return }
        
        let content = self.articleManager.loadResource(resource: resource, language: language, forceDownload: forceDownload)
        self.xmlPagesForPrimaryLang = content.pages
    }
    
    func loadResourcesForParallelLanguage(forceDownload: Bool) {
        if parallelLanguageIsAvailable() {
            let content = self.articleManager.loadResource(resource: self.resource!, language: parallelLanguage!, forceDownload: forceDownload)
            self.xmlPagesForParallelLang = content.pages
        }
    }

    func usePrimaryLanguageResources() {
        self.selectedLanguage = resolvePrimaryLanguage()
        self.xmlPages = self.xmlPagesForPrimaryLang
    }
    
    func useParallelLanguageResources() {
        self.selectedLanguage = parallelLanguage
        self.xmlPages = self.xmlPagesForParallelLang
    }

    func parallelLanguageIsAvailable() -> Bool {
        if parallelLanguage == nil {
            return false
        }
        return resource!.isDownloadedInLanguage(parallelLanguage)
    }

    func resolvePrimaryLanguage() -> Language? {
        if arrivedByUniversalLink {
            return universalLinkLanguage
        } else {
            return primaryLanguage
        }
    }

}



extension ArticleViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.cellID) as! ArticleTableViewCell
        
        // TODO: refactor to ViewModel
        let category = articleManager.categories[indexPath.row]
        let image = articleManager.getImage(forCategory: category)
        cell.imgView.image = image
        cell.titleLabel.text = articleManager.getTitle(forCategory: category)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleManager.categories.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = articleManager.categories[indexPath.row]
        presentArticlesList(category: category)
    }
    
    
    
    func presentArticlesList(category: XMLArticleCategory?) {
        guard let category = category else {
            return
        }
                
        let vc = ArticleCategoriesViewController.create()
        vc.category = category
        vc.articlesPath = articleManager.articlesPath
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
