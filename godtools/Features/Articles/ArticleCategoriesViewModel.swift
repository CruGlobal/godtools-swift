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
    
    private let resource: ResourceModel
    private let resourcesService: ResourcesService
    private let articlesService: ArticlesService
    private let analytics: AnalyticsContainer
        
    private weak var flowDelegate: FlowDelegate?
    
    let categories: ObservableValue<[ArticleCategory]> = ObservableValue(value: [])
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let loadingMessage: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessage> = ObservableValue(value: ArticlesErrorMessage(message: "", hidesErrorMessage: true, shouldAnimate: false))
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, resourcesService: ResourcesService, articlesService: ArticlesService, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.resourcesService = resourcesService
        self.articlesService = articlesService
        self.analytics = analytics
                        
        navTitle.accept(value: resource.name)
        
        //reloadArticles(godToolsResource: godToolsResource, forceDownload: false, animated: false)
    }
    
    deinit {
        
    }
    
    private func reloadArticles(godToolsResource: GodToolsResource, forceDownload: Bool, animated: Bool) {
        
        errorMessage.accept(value: ArticlesErrorMessage(message: "", hidesErrorMessage: true, shouldAnimate: animated))
        
        loadingMessage.accept(value: NSLocalizedString("articles.loadingView.downloadingArticles", comment: ""))
        isLoading.accept(value: true)
        
        articlesService.downloadAndCacheArticleData(godToolsResource: godToolsResource, forceDownload: forceDownload) { [weak self] (result: Result<ArticleManifestXmlParser, ArticlesServiceError>) in
           
            DispatchQueue.main.async { [weak self] in
                
                self?.loadingMessage.accept(value: "")
                self?.isLoading.accept(value: false)
                                
                switch result {
                    
                case .success(let articleManifest):
                    self?.categories.accept(value: articleManifest.categories)
                case .failure(let error):
                    
                    if let cachedManfiest = self?.articlesService.getCachedArticlesManifestXml(godToolsResource: godToolsResource) {
                        self?.categories.accept(value: cachedManfiest.categories)
                    }
                    else {
                        self?.categories.accept(value: [])
                        
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
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Categories", siteSection: resource.abbreviation, siteSubSection: "")
    }
    
    func downloadArticlesTapped() {
        //reloadArticles(godToolsResource: godToolsResource, forceDownload: true, animated: true)
    }
    
    func refreshArticles() {
        //reloadArticles(godToolsResource: godToolsResource, forceDownload: true, animated: true)
    }
    
    func articleTapped(category: ArticleCategory) {
        
        //flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(resource: resource, godToolsResource: godToolsResource, category: category))
    }
}
