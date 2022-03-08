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
    private var continueArticleDownloadReceipt: ArticleManifestDownloadArticlesReceipt?
    private var downloadArticlesReceipt: ArticleManifestDownloadArticlesReceipt?
    
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
        self.continueArticleDownloadReceipt = currentArticleDownloadReceipt
        
        super.init()
                        
        navTitle.accept(value: category.title)

        let cachedArticles: [AemUri] = getCachedArticles()
        
        reloadArticles(aemUris: cachedArticles)
        
        // currently downloading
        if let continueArticleDownloadReceipt = continueArticleDownloadReceipt {
            continueArticlesDownload(downloadArticlesReceipt: continueArticleDownloadReceipt)
        }
        else if cachedArticles.isEmpty {
            downloadArticles(forceDownload: true)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        continueArticleDownloadReceipt?.removeAllObserversFrom(object: self)
        downloadArticlesReceipt?.cancel()
    }
    
    private var analyticsScreenName: String {
        return "Category : \(category.title)"
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return "articles-list"
    }
    
    private var shouldShowLoadingIndicator: Bool {
        return numberOfArticles.value == 0
    }
    
    private func continueArticlesDownload(downloadArticlesReceipt: ArticleManifestDownloadArticlesReceipt) {
        
        if shouldShowLoadingIndicator {
            isLoading.accept(value: true)
        }
        
        downloadArticlesReceipt.completed.addObserver(self) { [weak self] (result: ArticleAemRepositoryResult?) in
            
            guard let viewModel = self else {
                return
            }
            
            guard let downloadResult = result else {
                return
            }
            
            DispatchQueue.main.async {
                viewModel.continueArticleDownloadReceipt?.removeAllObserversFrom(object: viewModel)
                viewModel.handleCompleteArticlesDownload(result: downloadResult)
            }
        }
    }
    
    private func downloadArticles(forceDownload: Bool) {
        
        if downloadArticlesReceipt != nil {
            return
        }
        
        if shouldShowLoadingIndicator {
            isLoading.accept(value: true)
        }
        
        errorMessage.accept(value: nil)
        
        downloadArticlesReceipt = articleManifestAemRepository.downloadAndCacheManifestAemUris(manifest: articleManifest, languageCode: translationZipFile.languageCode, forceDownload: forceDownload) { [weak self] (result: ArticleAemRepositoryResult) in
            self?.downloadArticlesReceipt = nil
            DispatchQueue.main.async { [weak self] in
                self?.handleCompleteArticlesDownload(result: result)
            }
        }
    }
    
    private func handleCompleteArticlesDownload(result: ArticleAemRepositoryResult) {
                
        isLoading.accept(value: false)
        
        let cachedArticles: [AemUri] = getCachedArticles()
        
        reloadArticles(aemUris: cachedArticles)
        
        if let downloadError = result.downloaderResult.downloadError, cachedArticles.isEmpty {
            
            let downloadArticlesErrorViewModel = DownloadArticlesErrorViewModel(
                localizationServices: localizationServices,
                error: downloadError
            )
            
            let errorViewModel = ArticlesErrorMessageViewModel(
                localizationServices: localizationServices,
                message: downloadArticlesErrorViewModel.message
            )
            
            errorMessage.accept(value: errorViewModel)
        }
        else {
            errorMessage.accept(value: nil)
        }
    }
    
    private func getCachedArticles() -> [AemUri] {
        
        let category: ArticleCategory = self.category
        let languageCode: String = translationZipFile.languageCode
        
        let categoryArticles: [CategoryArticleModel] = articleManifestAemRepository.getCategoryArticles(
            category: category,
            languageCode: languageCode
        )
        
        var aemUris: Set<String> = Set()
        
        for article in categoryArticles {
            for uri in article.aemUris {
                aemUris.insert(uri)
            }
        }
        
        return aemUris.sorted()
    }
    
    private func reloadArticles(aemUris: [AemUri]) {
        
        self.articles = aemUris
        numberOfArticles.accept(value: aemUris.count)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
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
