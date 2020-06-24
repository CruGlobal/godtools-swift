//
//  ArticleCategoriesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ArticleCategoriesViewModel: NSObject, ArticleCategoriesViewModelType {
    
    private let resource: ResourceModel
    private let translationManifest: TranslationManifest
    private let articleAemImportDownloader: ArticleAemImportDownloader
    private let analytics: AnalyticsContainer
    private let articleManifest: ArticleManifestXmlParser
    private let downloadArticlesReceipt: ArticleAemImportDownloaderReceipt
    
    private weak var flowDelegate: FlowDelegate?
    
    let translationsFileCache: TranslationsFileCache
    let categories: ObservableValue<[ArticleCategory]> = ObservableValue(value: [])
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let loadingMessage: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessage> = ObservableValue(value: ArticlesErrorMessage(message: "", hidesErrorMessage: true, shouldAnimate: false))
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, translationManifest: TranslationManifest, articleAemImportDownloader: ArticleAemImportDownloader, translationsFileCache: TranslationsFileCache, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.translationManifest = translationManifest
        self.articleAemImportDownloader = articleAemImportDownloader
        self.translationsFileCache = translationsFileCache
        self.analytics = analytics
        self.articleManifest = ArticleManifestXmlParser(xmlData: translationManifest.manifestXml)
        self.downloadArticlesReceipt = articleAemImportDownloader.getDownloadReceipt(translationManifest: translationManifest)
        
        super.init()
        
        setupBinding()
                        
        navTitle.accept(value: resource.name)
        
        reloadCategories()
        
        reloadArticles(forceDownload: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        downloadArticlesReceipt.started.removeObserver(self)
        downloadArticlesReceipt.completed.removeObserver(self)
        downloadArticlesReceipt.cancel()
    }
    
    private func setupBinding() {
        
        let articleManifest: ArticleManifestXmlParser = self.articleManifest
        
        downloadArticlesReceipt.started.addObserver(self) { [weak self] (started: Bool) in
            DispatchQueue.main.async { [weak self] in
                self?.isLoading.accept(value: started)
            }
        }
        
        downloadArticlesReceipt.completed.addObserver(self) { [weak self] (result: ArticleAemImportDownloaderResult) in
            DispatchQueue.main.async { [weak self] in
                
                self?.reloadCategories()
                                
                if let error = result.downloadError, articleManifest.categories.isEmpty {
                                        
                    let errorViewModel = DownloadArticlesErrorViewModel(error: error)
                    
                    self?.errorMessage.accept(
                        value: ArticlesErrorMessage(
                            message: errorViewModel.message,
                            hidesErrorMessage: false,
                            shouldAnimate: true
                    ))
                }
            }
        }
    }
    
    private func reloadArticles(forceDownload: Bool) {
            
        let articlesCached: Bool = articleAemImportDownloader.articlesCached(translationManifest: translationManifest)
        let articlesCacheExpired: Bool = articleAemImportDownloader.articlesCacheExpired(translationManifest: translationManifest)
        let downloadRunning: Bool = downloadArticlesReceipt.started.value
        
        if (!articlesCached || articlesCacheExpired || forceDownload) && !downloadRunning {
                                    
            _ = articleAemImportDownloader.downloadAndCache(
                translationManifest: translationManifest,
                aemImportSrcs: articleManifest.aemImportSrcs
            )
        }
    }
    
    private func reloadCategories() {
        categories.accept(value: articleManifest.categories)
    }

    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Categories", siteSection: resource.abbreviation, siteSubSection: "")
    }
    
    func downloadArticlesTapped() {
        reloadArticles(forceDownload: true)
    }
    
    func refreshArticles() {
        reloadArticles(forceDownload: true)
    }
    
    func articleTapped(category: ArticleCategory) {
        flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(resource: resource, translationManifest: translationManifest, category: category, articleManifest: articleManifest))
    }
}
