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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        loadLanguages()
        getResourceData()

    }

    func defineObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadView),
                                               name: .downloadPrimaryTranslationCompleteNotification,
                                               object: nil)
    }


    @objc private func reloadView() {
        tableView.reloadData()
    }

    
    
    func getResourceData() {
        loadResourcesForLanguage()
        loadResourcesForParallelLanguage()
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

    func loadResourcesForLanguage() {
        guard let language = resolvePrimaryLanguage() else { return }
        guard let resource = resource else { return }
        
        let content = self.articleManager.loadResource(resource: resource, language: language)
        self.xmlPagesForPrimaryLang = content.pages
    }
    
    func loadResourcesForParallelLanguage() {
        if parallelLanguageIsAvailable() {
            let content = self.articleManager.loadResource(resource: self.resource!, language: parallelLanguage!)
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
        
        // refactor to ViewModel
        let category = articleManager.categories![indexPath.row]
        let image = articleManager.getImage(forCategory: category)
        cell.imgView.image = image
        cell.titleLabel.text = articleManager.getTitle(forCategory: category)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleManager.categories!.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = articleManager.categories![indexPath.row]
        presentArticlesList(category: category)
    }
    
    
    
    func presentArticlesList(category: XMLArticleCategory?) {
        guard let category = category else {
            return
        }
        
        
        // extract ArticleData for the category
        let tags = category.aemTagIDs().map {
            articleManager.articlesDataForTag[$0]
        }
        
//        var artData = [ArticleData]()
        var artSetData = Set<ArticleData>()
        for tag in tags {
            guard let tag = tag else {
                // ignore nil articles -> relax possible xml/metadata errors
                continue
            }
            for artD in tag {
                artSetData.insert(artD)
            }
        }
        
        let artData = Array(artSetData).sorted()
        
        let vc = ArticleCategoriesViewController.create()
        vc.data = artData
        vc.category = category
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
