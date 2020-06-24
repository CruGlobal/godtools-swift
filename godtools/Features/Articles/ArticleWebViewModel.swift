//
//  ArticleWebViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleWebViewModel: ArticleWebViewModelType {
    
    private let resource: ResourceModel
    private let translationManifest: TranslationManifest
    private let articleAemImportData: ArticleAemImportData
    private let articleAemImportDownloader: ArticleAemImportDownloader
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let hidesShareButton: ObservableValue<Bool> = ObservableValue(value: false)
    let webUrl: ObservableValue<URL?> = ObservableValue(value: nil)
    let webArchiveUrl: ObservableValue<URL?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, translationManifest: TranslationManifest, articleAemImportData: ArticleAemImportData, articleAemImportDownloader: ArticleAemImportDownloader, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.translationManifest = translationManifest
        self.articleAemImportData = articleAemImportData
        self.articleAemImportDownloader = articleAemImportDownloader
        self.analytics = analytics
        
        navTitle.accept(value: articleAemImportData.articleJcrContent?.title ?? "")
        
        let translationZipFile: TranslationZipFileModel = translationManifest.translationZipFile
        var cachedWebArchiveUrl: URL?
        let webArchiveLocation = ArticleAemWebArchiveFileCacheLocation(
            resourceId: translationZipFile.resourceId,
            languageCode: translationZipFile.languageCode,
            filename: articleAemImportData.webArchiveFilename
        )
        
        switch articleAemImportDownloader.webArchiveFileCache.getFile(location: webArchiveLocation) {
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
            siteSection: resource.abbreviation,
            siteSubSection: "article"
        )
    }
    
    func sharedTapped() {
        
        flowDelegate?.navigate(step: .sharedTappedFromArticle(articleAemImportData: articleAemImportData))
    }
}
