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
    private let articleManifestAemRepository: ArticleManifestAemRepository
    private let localizationServices: LocalizationServices
    private let analytics: AnalyticsContainer
        
    private var articles: [AemUri] = Array()
    private var currentArticleDownloadReceipt: ArticleManifestDownloadArticlesReceipt?
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let numberOfArticles: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessageViewModel?> = ObservableValue(value: nil)
        
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, translationZipFile: TranslationZipFileModel, category: ArticleCategory, articleManifest: ArticleManifestXmlParser, articleManifestAemRepository: ArticleManifestAemRepository, localizationServices: LocalizationServices, analytics: AnalyticsContainer, currentArticleDownloadReceipt: ArticleManifestDownloadArticlesReceipt?) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.translationZipFile = translationZipFile
        self.category = category
        self.articleManifest = articleManifest
        self.articleManifestAemRepository = articleManifestAemRepository
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.currentArticleDownloadReceipt = currentArticleDownloadReceipt
        
        super.init()
                        
        navTitle.accept(value: category.title)

        let cachedArticles: [AemUri] = getCachedArticles()
        
        reloadArticles(aemUris: cachedArticles)
        
        // currently downloading
        if let currentArticleDownloadReceipt = currentArticleDownloadReceipt {
            continueArticlesDownload(downloadArticlesReceipt: currentArticleDownloadReceipt)
        }
        else if cachedArticles.isEmpty {
            downloadArticles(forceDownload: true)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        currentArticleDownloadReceipt?.removeAllObserversFrom(object: self)
    }
    
    private var shouldShowLoadingIndicator: Bool {
        return numberOfArticles.value == 0
    }
    
    private func continueArticlesDownload(downloadArticlesReceipt: ArticleManifestDownloadArticlesReceipt) {
        
        if shouldShowLoadingIndicator {
            isLoading.accept(value: true)
        }
        
        downloadArticlesReceipt.completed.addObserver(self) { [weak self] (result: ArticleAemRepositoryResult?) in
            DispatchQueue.main.async { [weak self] in
                if let result = result {
                    self?.handleCompleteArticlesDownload(result: result)
                }
            }
        }
    }
    
    private func downloadArticles(forceDownload: Bool) {
        
        if shouldShowLoadingIndicator {
            isLoading.accept(value: true)
        }
        
        _ = articleManifestAemRepository.downloadAndCacheManifestAemUris(manifest: articleManifest, languageCode: translationZipFile.languageCode, forceDownload: forceDownload) { [weak self] (result: ArticleAemRepositoryResult) in
            DispatchQueue.main.async { [weak self] in
                self?.handleCompleteArticlesDownload(result: result)
            }
        }
    }
    
    private func handleCompleteArticlesDownload(result: ArticleAemRepositoryResult) {
        
        // TODO: Need to handle network errors if network is not connected. ~Levi
        
        isLoading.accept(value: false)
        
        reloadArticles(aemUris: getCachedArticles())
    }
    
    private func getCachedArticles() -> [AemUri] {
        
        let category: ArticleCategory = self.category
        let languageCode: String = translationZipFile.languageCode
        
        let categoryArticles: [CategoryArticleModel] = articleManifestAemRepository.getCategoryArticles(
            category: category,
            languageCode: languageCode
        )
        
        var aemUris: [AemUri] = Array()
        
        for article in categoryArticles {
            aemUris.append(contentsOf: article.aemUris)
        }
        
        return aemUris
    }
    
    private func reloadArticles(aemUris: [AemUri]) {
        
        self.articles = aemUris
        numberOfArticles.accept(value: aemUris.count)
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Category : \(category.title)", siteSection: resource.abbreviation, siteSubSection: "articles-list")
    }
    
    func articleTapped(index: Int) {
        
        let aemUri: String = articles[index]
        
        guard let aemCacheObject = articleManifestAemRepository.getAemCacheObject(aemUri: aemUri) else {
            return
        }
        
        flowDelegate?.navigate(step: .articleTappedFromArticles(resource: resource, aemCacheObject: aemCacheObject))
    }
    
    func articleWillAppear(index: Int) -> ArticleCellViewModelType? {
        
        let aemUri: String = articles[index]
    
        guard let aemCacheObject = articleManifestAemRepository.getAemCacheObject(aemUri: aemUri) else {
            return nil
        }
        
        return ArticleCellViewModel(aemData: aemCacheObject.aemData)
    }
    
    func downloadArticlesTapped() {
        downloadArticles(forceDownload: true)
    }
}
