//
//  ArticleCategoriesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ArticleCategoriesViewModel: ArticleCategoriesViewModelType {
    
    private let resource: DownloadedResource
    private let articlesService: ArticlesService
    private let articleAemImportService: ArticleAemImportService
    private let analytics: AnalyticsContainer
        
    private weak var flowDelegate: FlowDelegate?
    
    let godToolsResource: GodToolsResource
    let resourceLatestTranslationServices: ResourceLatestTranslationServices
    let categories: ObservableValue<[ArticleCategory]> = ObservableValue(value: [])
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let loadingMessage: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticleCategoriesErrorMessage> = ObservableValue(value: ArticleCategoriesErrorMessage(title: "", message: "", downloadArticlesButtonTitle: "", hidesDownloadArticlesButton: false, hidesErrorMessage: true, shouldAnimate: false))
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, godToolsResource: GodToolsResource, articlesService: ArticlesService, resourceLatestTranslationServices: ResourceLatestTranslationServices, articleAemImportService: ArticleAemImportService, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.godToolsResource = godToolsResource
        self.articlesService = articlesService
        self.articleAemImportService = articleAemImportService
        self.resourceLatestTranslationServices = resourceLatestTranslationServices
        self.analytics = analytics
                
        navTitle.accept(value: resource.name)
        
        reloadArticles(forceDownload: false, animated: false)
    }
    
    deinit {
        
        articlesService.cancel()
    }
    
    private func reloadArticles(forceDownload: Bool, animated: Bool) {
        
        errorMessage.accept(value: ArticleCategoriesErrorMessage(title: "", message: "", downloadArticlesButtonTitle: "", hidesDownloadArticlesButton: false, hidesErrorMessage: true, shouldAnimate: animated))
        
        loadingMessage.accept(value: NSLocalizedString("articles.loadingView.downloadingArticles", comment: ""))
        isLoading.accept(value: true)
        
        articlesService.downloadAndCacheArticleData(godToolsResource: godToolsResource, forceDownload: forceDownload) { [weak self] (result: Result<ArticleManifestXmlParser, Error>) in
           
            DispatchQueue.main.async { [weak self] in
                
                self?.loadingMessage.accept(value: "")
                self?.isLoading.accept(value: false)
                                
                switch result {
                    
                case .success(let articleManifest):
                    self?.categories.accept(value: articleManifest.categories)
                case .failure(let error):
                    self?.categories.accept(value: [])
                    let errorTitle: String = NSLocalizedString("articles.downloadingArticles.errorMessage.title", comment: "")
                    let errorMessage: String = error.localizedDescription
                    self?.errorMessage.accept(
                        value: ArticleCategoriesErrorMessage(
                            title: errorTitle,
                            message: errorMessage,
                            downloadArticlesButtonTitle: NSLocalizedString("articles.downloadArticlesButton.title.retryDownload", comment: ""),
                            hidesDownloadArticlesButton: false,
                            hidesErrorMessage: false,
                            shouldAnimate: true
                    ))
                }
            }
        }
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Categories", siteSection: resource.code, siteSubSection: "")
    }
    
    func downloadArticlesTapped() {
        reloadArticles(forceDownload: true, animated: true)
    }
    
    func refreshArticles() {
        reloadArticles(forceDownload: true, animated: true)
    }
    
    func articleTapped(category: ArticleCategory) {
        
        flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(resource: resource, godToolsResource: godToolsResource, category: category))
    }
}
