//
//  ArticleCategoriesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import GodToolsToolParser

class ArticleCategoriesViewModel: NSObject {
        
    private let resource: ResourceModel
    private let language: LanguageDomainModel
    private let manifest: Manifest
    private let articleManifestAemRepository: ArticleManifestAemRepository
    private let localizationServices: LocalizationServices
    private let manifestResourcesCache: ManifestResourcesCache
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    
    private var categories: [GodToolsToolParser.Category] = Array()
    private var downloadArticlesReceipt: ArticleManifestDownloadArticlesReceipt?
    
    private weak var flowDelegate: FlowDelegate?
    
    let numberOfCategories: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
        
    init(flowDelegate: FlowDelegate, resource: ResourceModel, language: LanguageDomainModel, manifest: Manifest, articleManifestAemRepository: ArticleManifestAemRepository, manifestResourcesCache: ManifestResourcesCache, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.language = language
        self.manifest = manifest
        self.articleManifestAemRepository = articleManifestAemRepository
        self.manifestResourcesCache = manifestResourcesCache
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        
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
        self.categories = manifest.categories
        numberOfCategories.accept(value: categories.count)
    }

    private func downloadArticles(forceDownload: Bool) {
        
        cancelArticleDownload()
        
        isLoading.accept(value: true)
        
        downloadArticlesReceipt = articleManifestAemRepository.downloadAndCacheManifestAemUris(manifest: manifest, languageCode: language.localeIdentifier, forceDownload: forceDownload, completion: { [weak self] (result: ArticleAemRepositoryResult) in
            
            DispatchQueue.main.async { [weak self] in
                self?.isLoading.accept(value: false)
            }
        })
    }
}

// MARK: - Inputs

extension ArticleCategoriesViewModel {
    
    func pageViewed() {
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
        analytics.appsFlyerAnalytics.trackAction(actionName: analyticsScreenName, data: nil)
    }
    
    func categoryWillAppear(index: Int) -> ArticleCategoryCellViewModel {
        
        let category: GodToolsToolParser.Category = categories[index]
        
        return ArticleCategoryCellViewModel(
            category: category,
            manifestResourcesCache: manifestResourcesCache
        )
    }
    
    func categoryTapped(index: Int) {
        
        let category: GodToolsToolParser.Category = categories[index]
        
        flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(resource: resource, language: language, category: category, manifest: manifest, currentArticleDownloadReceipt: downloadArticlesReceipt))
    }
    
    func refreshArticles() {
        downloadArticles(forceDownload: true)
    }
    
    func backButtonTapped() {
        flowDelegate?.navigate(step: .backTappedFromArticleCategories)
    }
}
