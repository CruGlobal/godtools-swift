//
//  ArticlesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticlesViewModel: NSObject, ArticlesViewModelType {
    
    typealias AemUri = String
    
    private let resource: ResourceModel
    private let translationZipFile: TranslationZipFileModel
    private let category: ArticleCategory
    private let articleManifest: ArticleManifestXmlParser
    private let articleManifestAemDownloader: ArticleManifestAemDownloader
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
        
    private var articles: [AemUri] = Array()
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let numberOfArticles: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessageViewModel?> = ObservableValue(value: nil)
    
    var downloadArticlesReceipt: ArticleManifestAemDownloadReceipt?
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, translationZipFile: TranslationZipFileModel, category: ArticleCategory, articleManifest: ArticleManifestXmlParser, articleManifestAemDownloader: ArticleManifestAemDownloader, localizationServices: LocalizationServices, analytics: AnalyticsContainer, currentArticleDownloadReceipt: ArticleManifestAemDownloadReceipt?) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.translationZipFile = translationZipFile
        self.category = category
        self.articleManifest = articleManifest
        self.articleManifestAemDownloader = articleManifestAemDownloader
        self.localizationServices = localizationServices
        self.analytics = analytics
        
        super.init()
                        
        navTitle.accept(value: category.title)

        let cachedArticles: [AemUri] = getCachedArticles()
        
        reloadArticles(aemUris: cachedArticles)
        
        // currently downloading
        if let currentArticleDownloadReceipt = currentArticleDownloadReceipt {
            addManifestDownloadReceiptObservers(manifestDownloadReceipt: currentArticleDownloadReceipt)
            downloadArticlesReceipt = currentArticleDownloadReceipt
        }
        else if cachedArticles.isEmpty {
            downloadArticles(forceDownload: true)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        destroyDownloadArticlesReceipt()
    }
    
    private func addManifestDownloadReceiptObservers(manifestDownloadReceipt: ArticleManifestAemDownloadReceipt) {
                
        addReceiptObservers(
            manifestDownloadReceipt: manifestDownloadReceipt,
            manifest: articleManifest,
            localizationServices: localizationServices
        )
        
        manifestDownloadReceipt.completed.addObserver(self) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.reloadArticles(aemUris: self?.getCachedArticles() ?? [])
                self?.destroyDownloadArticlesReceipt()
            }
        }
    }
    
    private func downloadArticles(forceDownload: Bool) {
        
        let downloadArticlesReceipt: ArticleManifestAemDownloadReceipt? = downloadArticles(
            downloader: articleManifestAemDownloader,
            manifest: articleManifest,
            languageCode: translationZipFile.languageCode,
            localizationServices: localizationServices,
            forceDownload: forceDownload
        )
        
        if let downloadArticlesReceipt = downloadArticlesReceipt {
            addManifestDownloadReceiptObservers(manifestDownloadReceipt: downloadArticlesReceipt)
        }
    }
    
    private func getCachedArticles() -> [AemUri] {
        
        let category: ArticleCategory = self.category
        let languageCode: String = translationZipFile.languageCode
        
        let categoryArticles: [CategoryArticleModel] = articleManifestAemDownloader.getCategoryArticles(
            category: category,
            languageCode: languageCode
        )
        
        var aemUris: [AemUri] = Array()
        
        for article in categoryArticles {
            aemUris.append(contentsOf: article.aemUris)
        }
        
        return aemUris
    }
    
    private func reloadArticles(aemUris: [String]) {
        
        self.articles = aemUris
        numberOfArticles.accept(value: aemUris.count)
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Category : \(category.title)", siteSection: resource.abbreviation, siteSubSection: "articles-list")
    }
    
    func articleTapped(index: Int) {
        
        let aemUri: String = articles[index]
        // TODO: Fetch ArticleAemImportData from cache with aemUri. ~Levi
        //let aemData: ArticleAemImportData = //... fetch from cache
        
        // TODO: Uncomment this line to complete navigation. ~Levi
        //flowDelegate?.navigate(step: .articleTappedFromArticles(resource: resource, translationZipFile: translationZipFile, articleAemImportData: aemData))
    }
    
    /*
    func articleWillAppear(index: Int) -> ArticleCellViewModelType {
        
        let aemUri: String = articles[index]
        // TODO: Fetch ArticleAemImportData from cache and return view model.
        //let aemData: ArticleAemImportData = //... fetch from cache
             
        return ArticleCellViewModel(articleAemImportData: aemData)
    }*/
    
    func downloadArticlesTapped() {
        downloadArticles(forceDownload: true)
    }
}
