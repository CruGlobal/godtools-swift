//
//  ArticlesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticlesViewModel: ArticlesViewModelType {
    
    private let resource: DownloadedResource
    private let godToolsResource: GodToolsResource
    private let category: ArticleCategory
    private let articlesService: ArticlesService
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let articleAemImportData: ObservableValue<[RealmArticleAemImportData]> = ObservableValue(value: [])
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessage> = ObservableValue(value: ArticlesErrorMessage(message: "", hidesErrorMessage: true, shouldAnimate: false))
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, godToolsResource: GodToolsResource, category: ArticleCategory, articlesService: ArticlesService, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.godToolsResource = godToolsResource
        self.category = category
        self.articlesService = articlesService
        self.analytics = analytics
        
        navTitle.accept(value: category.title)
        
        reloadArticles(category: category, animated: false)
    }
    
    deinit {
        articlesService.cancel()
    }
    
    private func reloadArticles(category: ArticleCategory, animated: Bool) {
        
        let cachedArticleImportData: [RealmArticleAemImportData] = articlesService.articleAemImportService.getArticlesWithTags(
            godToolsResource: godToolsResource,
            aemTags: category.aemTags
        )
        
        if cachedArticleImportData.isEmpty {
            
            errorMessage.accept(value: ArticlesErrorMessage(message: "", hidesErrorMessage: true, shouldAnimate: animated))
            
            isLoading.accept(value: true)
            
            articlesService.downloadAndCacheArticleData(godToolsResource: godToolsResource, forceDownload: true) { [weak self] (result: Result<ArticleManifestXmlParser, Error>) in
               
                DispatchQueue.main.async { [weak self] in
                    
                    self?.isLoading.accept(value: false)
                                    
                    switch result {
                        
                    case .success( _):
                        self?.reloadArticleAemImportDataFromCache(category: category)
                    case .failure( let error):
                        let errorMessage: String = error.localizedDescription
                        self?.errorMessage.accept(
                            value: ArticlesErrorMessage(
                                message: errorMessage,
                                hidesErrorMessage: false,
                                shouldAnimate: true
                        ))
                    }
                }
            }
        }
        else {
            reloadArticleAemImportDataFromCache(category: category)
        }
    }
    
    private func reloadArticleAemImportDataFromCache(category: ArticleCategory) {
                
        var cachedArticleImportDataArray: [RealmArticleAemImportData] = articlesService.articleAemImportService.getArticlesWithTags(godToolsResource: godToolsResource, aemTags: category.aemTags)
        cachedArticleImportDataArray.sort {(rhs: RealmArticleAemImportData, lhs: RealmArticleAemImportData) in
            rhs.articleJcrContent?.title?.lowercased() ?? "" < lhs.articleJcrContent?.title?.lowercased() ?? ""
        }
        
        articleAemImportData.accept(value: cachedArticleImportDataArray)
    }
    
    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Category : \(category.title)", siteSection: resource.code, siteSubSection: "articles-list")
    }
    
    func articleTapped(articleAemImportData: RealmArticleAemImportData) {
        flowDelegate?.navigate(step: .articleTappedFromArticles(resource: resource, godToolsResource: godToolsResource, articleAemImportData: articleAemImportData))
    }
    
    func downloadArticlesTapped() {
        reloadArticles(category: category, animated: true)
    }
}
