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
    private let articleManifestAemRepository: ArticleManifestAemRepository
    private let localizationServices: LocalizationServices
    private let translationsFileCache: TranslationsFileCache
    private let analytics: AnalyticsContainer
    private let articleManifest: ArticleManifestXmlParser
    
    private var categories: [ArticleCategory] = Array()
    private var downloadArticlesReceipt: ArticleManifestDownloadArticlesReceipt?
    
    private weak var flowDelegate: FlowDelegate?
    
    let numberOfCategories: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
        
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, translationManifest: TranslationManifestData, articleManifestAemRepository: ArticleManifestAemRepository, translationsFileCache: TranslationsFileCache, localizationServices: LocalizationServices, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.translationZipFile = translationManifest.translationZipFile
        self.articleManifestAemRepository = articleManifestAemRepository
        self.translationsFileCache = translationsFileCache
        self.localizationServices = localizationServices
        self.analytics = analytics
        self.articleManifest = ArticleManifestXmlParser(xmlData: translationManifest.manifestXmlData)
        
        super.init()
                                            
        reloadCategories()
        
        downloadArticles(forceDownload: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        cancelArticleDownload()
    }
    
    private var analyticsScreenName: String {
        return "categories"
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    private func cancelArticleDownload() {
        downloadArticlesReceipt?.cancel()
        downloadArticlesReceipt = nil
    }
    
    private func reloadCategories() {
        self.categories = articleManifest.categories
        numberOfCategories.accept(value: categories.count)
    }

    private func downloadArticles(forceDownload: Bool) {
          
        cancelArticleDownload()
        
        isLoading.accept(value: true)
        
        downloadArticlesReceipt = articleManifestAemRepository.downloadAndCacheManifestAemUris(manifest: articleManifest, languageCode: translationZipFile.languageCode, forceDownload: forceDownload, completion: { [weak self] (result: ArticleAemRepositoryResult) in
            
            DispatchQueue.main.async { [weak self] in
                self?.isLoading.accept(value: false)
            }
        })
    }

    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
        analytics.appsFlyerAnalytics.trackAction(actionName: analyticsScreenName, data: nil)
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
    
    func refreshArticles() {
        downloadArticles(forceDownload: true)
    }
    
    func backButtonTapped() {
        flowDelegate?.navigate(step: .backTappedFromArticleCategories)
    }
}
