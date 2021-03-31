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
    private let translationZipFile: TranslationZipFileModel
    private let articleManifestAemDownloader: ArticleManifestAemDownloader
    private let localizationServices: LocalizationServices
    private let translationsFileCache: TranslationsFileCache
    private let analytics: AnalyticsContainer
    private let articleManifest: ArticleManifestXmlParser
    
    private var categories: [ArticleCategory] = Array()
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let numberOfCategories: ObservableValue<Int> = ObservableValue(value: 0)
    let loadingMessage: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessageViewModel?> = ObservableValue(value: nil)
    
    var downloadArticlesReceipt: ArticleManifestAemDownloadReceipt?
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, translationManifest: TranslationManifestData, articleManifestAemDownloader: ArticleManifestAemDownloader, translationsFileCache: TranslationsFileCache, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.translationZipFile = translationManifest.translationZipFile
        self.articleManifestAemDownloader = articleManifestAemDownloader
        self.translationsFileCache = translationsFileCache
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.articleManifest = ArticleManifestXmlParser(xmlData: translationManifest.manifestXmlData)
        
        super.init()
                                
        navTitle.accept(value: resource.name)
            
        reloadCategories()
        
        downloadArticles(forceDownload: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        destroyDownloadArticlesReceipt()
    }
    
    private func reloadCategories() {
     
        self.categories = articleManifest.categories
        numberOfCategories.accept(value: categories.count)
    }

    private func downloadArticles(forceDownload: Bool) {
            
        downloadArticles(
            downloader: articleManifestAemDownloader,
            manifest: articleManifest,
            languageCode: translationZipFile.languageCode,
            localizationServices: localizationServices,
            forceDownload: forceDownload
        )
    }

    func pageViewed() {
        analytics.pageViewedAnalytics.trackPageView(screenName: "Categories", siteSection: resource.abbreviation, siteSubSection: "")
    }
    
    func categoryWillAppear(index: Int) -> ArticleCategoryCellViewModelType {
        
        let category: ArticleCategory = categories[index]
        
        return ArticleCategoryCellViewModel(
            category: category,
            translationsFileCache: translationsFileCache
        )
    }
    
    func categoryTapped(index: Int) {
        
        let category: ArticleCategory = categories[index]
        
        flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(resource: resource, translationZipFile: translationZipFile, category: category, articleManifest: articleManifest, currentArticleDownloadReceipt: downloadArticlesReceipt))
    }
    
    func downloadArticlesTapped() {
        downloadArticles(forceDownload: true)
    }
    
    func refreshArticles() {
        downloadArticles(forceDownload: true)
    }
}
