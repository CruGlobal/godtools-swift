//
//  ArticleWebViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleWebViewModel: ArticleWebViewModelType {
    
    private let resource: DownloadedResource
    private let godToolsResource: GodToolsResource
    private let articleAemImportData: RealmArticleAemImportData
    private let articlesService: ArticlesService
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let hidesShareButton: ObservableValue<Bool> = ObservableValue(value: false)
    let webUrl: ObservableValue<URL?> = ObservableValue(value: nil)
    let webArchiveUrl: ObservableValue<URL?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, godToolsResource: GodToolsResource, articleAemImportData: RealmArticleAemImportData, articlesService: ArticlesService, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.godToolsResource = godToolsResource
        self.articleAemImportData = articleAemImportData
        self.articlesService = articlesService
        self.analytics = analytics
        
        navTitle.accept(value: articleAemImportData.articleJcrContent?.title ?? "")
        
        var cachedWebArchiveUrl: URL?
        let webArchiveLocation = ArticleAemWebArchiveFileCacheLocation(
            godToolsResource: godToolsResource,
            filename: articleAemImportData.webArchiveFilename
        )
        
        switch articlesService.articleAemImportService.aemWebArchiveFileCache.getFile(location: webArchiveLocation) {
        case .success(let url):
            cachedWebArchiveUrl = url
        case .failure( _):
            cachedWebArchiveUrl = nil
        }
        
        if let cachedWebArchiveUrl = cachedWebArchiveUrl {
            webArchiveUrl.accept(value: cachedWebArchiveUrl)
        }
        else if let articleWebUrl = URL(string: articleAemImportData.webUrl) {
            webUrl.accept(value: articleWebUrl)
        }
        
        hidesShareButton.accept(value: articleAemImportData.articleJcrContent?.canonical == nil)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(
            screenName: "Article : \(articleAemImportData.articleJcrContent?.title ?? "")",
            siteSection: resource.code,
            siteSubSection: "article"
        )
    }
    
    func sharedTapped() {
        
        flowDelegate?.navigate(step: .sharedTappedFromArticle(articleAemImportData: articleAemImportData))
    }
}
