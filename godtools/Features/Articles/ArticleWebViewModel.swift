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
    private let articleAemImportService: ArticleAemImportService
    private let analytics: GodToolsAnaltyics
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let webUrl: ObservableValue<URL?> = ObservableValue(value: nil)
    let webArchiveUrl: ObservableValue<URL?> = ObservableValue(value: nil)
    
    required init(resource: DownloadedResource, godToolsResource: GodToolsResource, articleAemImportData: RealmArticleAemImportData, articleAemImportService: ArticleAemImportService, analytics: GodToolsAnaltyics) {
        
        self.resource = resource
        self.godToolsResource = godToolsResource
        self.articleAemImportData = articleAemImportData
        self.articleAemImportService = articleAemImportService
        self.analytics = analytics
        
        navTitle.accept(value: articleAemImportData.articleJcrContent?.title ?? "")
        
        var cachedWebArchiveUrl: URL?
        let webArchiveLocation = ArticleAemWebArchiveFileCacheLocation(
            godToolsResource: godToolsResource,
            filename: articleAemImportData.webArchiveFilename
        )
        
        switch articleAemImportService.aemWebArchiveFileCache.getFile(location: webArchiveLocation) {
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
    }
    
    func pageViewed() {
        
        analytics.recordScreenView(
            screenName: "Article : \(articleAemImportData.articleJcrContent?.title ?? "")",
            siteSection: resource.code,
            siteSubSection: "article"
        )
    }
}
