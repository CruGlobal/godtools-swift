//
//  ArticlesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticlesViewModel: NSObject, ArticlesViewModelType {
    
    private let resource: ResourceModel
    private let translationManifest: TranslationManifest
    private let category: ArticleCategory
    private let articleManifest: ArticleManifestXmlParser
    private let articleAemImportDownloader: ArticleAemImportDownloader
    private let analytics: AnalyticsContainer
    private let downloadArticlesReceipt: ArticleAemImportDownloaderReceipt
        
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let articleAemImportData: ObservableValue<[ArticleAemImportData]> = ObservableValue(value: [])
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessage> = ObservableValue(value: ArticlesErrorMessage(message: "", hidesErrorMessage: true, shouldAnimate: false))
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, translationManifest: TranslationManifest, category: ArticleCategory, articleManifest: ArticleManifestXmlParser, articleAemImportDownloader: ArticleAemImportDownloader, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.translationManifest = translationManifest
        self.category = category
        self.articleManifest = articleManifest
        self.articleAemImportDownloader = articleAemImportDownloader
        self.analytics = analytics
        self.downloadArticlesReceipt = articleAemImportDownloader.getDownloadReceipt(translationManifest: translationManifest)
        
        super.init()
        
        setupBinding()
        
        navTitle.accept(value: category.title)
        
        reloadArticlesIfNeeded()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        downloadArticlesReceipt.started.removeObserver(self)
        downloadArticlesReceipt.completed.removeObserver(self)
    }
    
    private var articlesCached: Bool {
        return articleAemImportDownloader.articlesCached(translationManifest: translationManifest)
    }
    
    private var articlesCacheExpired: Bool {
        return articleAemImportDownloader.articlesCacheExpired(translationManifest: translationManifest)
    }
    
    private var shouldShowArticlesList: Bool {
        return articlesCached
    }
    
    private var showLoadingArticles: Bool {
        !shouldShowArticlesList
    }
    
    private func setupBinding() {
                     
        downloadArticlesReceipt.started.addObserver(self) { [weak self] (started: Bool) in
            DispatchQueue.main.async { [weak self] in
                let showLoadingArticles: Bool = self?.showLoadingArticles ?? false
                self?.isLoading.accept(value: started && showLoadingArticles)
            }
        }
        
        downloadArticlesReceipt.completed.addObserver(self) { [weak self] (result: ArticleAemImportDownloaderResult) in
            DispatchQueue.main.async { [weak self] in
                
                guard let category = self?.category else {
                    return
                }
                
                self?.reloadArticleAemImportDataFromCache(category: category, completeOnMain: { (cachedArticleData: [ArticleAemImportData]) in
                    
                    let articlesCached: Bool = self?.articlesCached ?? false
                    let showDownloadError: Bool = !articlesCached
                    
                    if let downloadError = result.downloadError, showDownloadError {
                        
                        let errorViewModel = DownloadArticlesErrorViewModel(error: downloadError)
                        
                        self?.errorMessage.accept(
                            value: ArticlesErrorMessage(
                                message: errorViewModel.message,
                                hidesErrorMessage: false,
                                shouldAnimate: true
                        ))
                    }
                })
            }
        }
    }
    
    private func reloadArticlesIfNeeded() {
        reloadArticleAemImportDataFromCache(category: category) { [weak self] (cachedArticles: [ArticleAemImportData]) in
            if cachedArticles.isEmpty {
                self?.reloadArticles(forceDownload: true)
            }
        }
    }
    
    private func reloadArticles(forceDownload: Bool) {
            
        let articleManifest: ArticleManifestXmlParser = self.articleManifest
        
        let downloadRunning: Bool = downloadArticlesReceipt.started.value
                
        if (!articlesCached || articlesCacheExpired || forceDownload) && !downloadRunning {
                                                
            _ = articleAemImportDownloader.downloadAndCache(
                translationManifest: translationManifest,
                aemImportSrcs: articleManifest.aemImportSrcs
            )
        }
    }
    
    private func reloadArticleAemImportDataFromCache(category: ArticleCategory, completeOnMain: @escaping ((_ cachedArticles: [ArticleAemImportData]) -> Void)) {
           
        if !shouldShowArticlesList {
            completeOnMain([])
            return
        }
        
        articleAemImportDownloader.getArticlesWithTags(translationManifest: translationManifest, aemTags: category.aemTags, completeOnMain: { [weak self] (cachedArticleImportDataArray: [ArticleAemImportData]) in
            
            let sortedArticles = cachedArticleImportDataArray.sorted {(rhs: ArticleAemImportData, lhs: ArticleAemImportData) in
                rhs.articleJcrContent?.title?.lowercased() ?? "" < lhs.articleJcrContent?.title?.lowercased() ?? ""
            }
            
            self?.articleAemImportData.accept(value: sortedArticles)
            
            completeOnMain(sortedArticles)
        })
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Category : \(category.title)", siteSection: resource.abbreviation, siteSubSection: "articles-list")
    }
    
    func articleTapped(articleAemImportData: ArticleAemImportData) {
        flowDelegate?.navigate(step: .articleTappedFromArticles(resource: resource, translationManifest: translationManifest, articleAemImportData: articleAemImportData))
    }
    
    func downloadArticlesTapped() {
        reloadArticles(forceDownload: true)
    }
}
