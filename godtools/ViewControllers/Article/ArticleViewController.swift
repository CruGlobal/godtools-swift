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
        return ArticleViewController(nibName: String(describing: ArticleViewController.self), bundle: nil)
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = articleManager
            tableView.dataSource = articleManager
        }
    }
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: String(describing: ArticleTableViewCell.self), bundle: nil), forCellReuseIdentifier: ArticleManager.cellIdentifier)
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
