//
//  ArticleCategoriesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import Combine

@MainActor class ArticleCategoriesViewModel {
        
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let resource: ResourceDataModel
    private let language: LanguageDataModel
    private let manifest: Manifest
    private let downloadArticlesObservable: DownloadManifestArticlesObservable
    private let manifestResourcesCache: MobileContentRendererManifestResourcesCache
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let categories: [GodToolsShared.Category]
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var pageViewCount: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let numberOfCategories: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
        
    init(flowDelegate: FlowDelegate, resource: ResourceDataModel, language: LanguageDataModel, manifest: Manifest, downloadArticlesObservable: DownloadManifestArticlesObservable, manifestResourcesCache: MobileContentRendererManifestResourcesCache, incrementUserCounterUseCase: IncrementUserCounterUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.language = language
        self.manifest = manifest
        self.downloadArticlesObservable = downloadArticlesObservable
        self.manifestResourcesCache = manifestResourcesCache
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
                
        categories = manifest.categories
        numberOfCategories.accept(value: categories.count)
                        
        downloadArticlesObservable
            .$isDownloading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isDownloading: Bool) in
                
                self?.isLoading.accept(value: isDownloading)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
}

// MARK: - Inputs

extension ArticleCategoriesViewModel {
    
    @objc func backTapped() {
        flowDelegate?.navigate(step: .backTappedFromArticleCategories)
    }
    
    func pageViewed() {
        
        if pageViewCount == 0 {
            
            incrementUserCounterUseCase
                .execute(
                    interaction: .toolOpen(tool: resource.id)
                )
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    
                } receiveValue: { _ in
                    
                }
                .store(in: &Self.backgroundCancellables)
        }
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
                
        pageViewCount += 1
    }
    
    func categoryWillAppear(index: Int) -> ArticleCategoryCellViewModel {
        
        let category: GodToolsShared.Category = categories[index]
        
        return ArticleCategoryCellViewModel(
            category: category,
            manifestResourcesCache: manifestResourcesCache
        )
    }
    
    func categoryTapped(index: Int) {
        
        let category: GodToolsShared.Category = categories[index]
        
        flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(resource: resource, language: language, category: category, manifest: manifest))
    }
    
    func refreshArticles() {
        
        downloadArticlesObservable.downloadArticles(downloadCachePolicy: .ignoreCache, forceFetchFromRemote: true)
    }
}
