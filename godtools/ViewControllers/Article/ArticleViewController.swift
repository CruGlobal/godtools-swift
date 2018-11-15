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
    var xmlPages = [XMLPage]()
    var xmlPagesForPrimaryLang = [XMLPage]()
    var xmlPagesForParallelLang = [XMLPage]()

    var arrivedByUniversalLink = false
    var universalLinkLanguage: Language?

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = articleManager
            tableView.dataSource = articleManager
        }
    }
    
    static func create() -> ArticleViewController {
        return ArticleViewController(nibName: String(describing: ArticleViewController.self), bundle: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        loadLanguages()
        getResourceData()

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
