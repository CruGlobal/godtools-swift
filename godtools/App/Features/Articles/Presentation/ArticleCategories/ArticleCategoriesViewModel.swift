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
import Combine

class ArticleCategoriesViewModel {
        
    private let resource: ResourceModel
    private let language: LanguageDomainModel
    private let manifest: Manifest
    private let articleManifestAemRepository: ArticleManifestAemRepository
    private let localizationServices: LocalizationServices
    private let manifestResourcesCache: MobileContentRendererManifestResourcesCache
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var categories: [GodToolsToolParser.Category] = Array()
    private var downloadArticlesReceipt: ArticleManifestDownloadArticlesReceipt?
    private var cancellables = Set<AnyCancellable>()
    private var pageViewCount: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let numberOfCategories: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
        
    init(flowDelegate: FlowDelegate, resource: ResourceModel, language: LanguageDomainModel, manifest: Manifest, articleManifestAemRepository: ArticleManifestAemRepository, manifestResourcesCache: MobileContentRendererManifestResourcesCache, localizationServices: LocalizationServices, incrementUserCounterUseCase: IncrementUserCounterUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.language = language
        self.manifest = manifest
        self.articleManifestAemRepository = articleManifestAemRepository
        self.manifestResourcesCache = manifestResourcesCache
        self.localizationServices = localizationServices
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
                                                    
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
        
        downloadArticlesReceipt = articleManifestAemRepository.downloadAndCacheManifestAemUrisReceipt(manifest: manifest, languageCode: language.localeIdentifier, forceDownload: forceDownload, completion: { [weak self] (result: ArticleAemRepositoryResult) in
            
            DispatchQueue.main.async { [weak self] in
                self?.isLoading.accept(value: false)
            }
        })
    }
}

// MARK: - Inputs

extension ArticleCategoriesViewModel {
    
    @objc func backTapped() {
        flowDelegate?.navigate(step: .backTappedFromArticleCategories)
    }
    
    func pageViewed() {
        
        if pageViewCount == 0 {
            
            incrementUserCounterUseCase.incrementUserCounter(for: .toolOpen(tool: resource.id))
                .sink { _ in
                    
                } receiveValue: { _ in
                    
                }
                .store(in: &cancellables)
        }
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
                
        pageViewCount += 1
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
}
