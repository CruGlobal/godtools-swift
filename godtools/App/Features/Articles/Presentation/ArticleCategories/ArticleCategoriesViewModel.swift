//
//  ArticleCategoriesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsShared

@MainActor
final class ArticleCategoriesViewModel: ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let resource: ResourceDataModel
    private let language: LanguageDataModel
    private let translation: TranslationDataModel
    private let manifest: Manifest
    private let getArticleCategoriesUseCase: GetArticleCategoriesUseCase
    private let pullToRefreshArticlesUseCase: PullToRefreshArticlesUseCase
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var pullToRefreshArticlesTask: Task<Void, Error>?
    private var pageViewCount: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private(set) var categories: [ArticleCategoryDomainModel] = Array()
    
    init(flowDelegate: FlowDelegate, resource: ResourceDataModel, language: LanguageDataModel, translation: TranslationDataModel, manifest: Manifest, getArticleCategoriesUseCase: GetArticleCategoriesUseCase, pullToRefreshArticlesUseCase: PullToRefreshArticlesUseCase, incrementUserCounterUseCase: IncrementUserCounterUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.language = language
        self.translation = translation
        self.manifest = manifest
        self.getArticleCategoriesUseCase = getArticleCategoriesUseCase
        self.pullToRefreshArticlesUseCase = pullToRefreshArticlesUseCase
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        categories = getArticleCategoriesUseCase.execute(manifest: manifest)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        pullToRefreshArticlesTask?.cancel()
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
    
    func categoryTapped(category: ArticleCategoryDomainModel) {
                
        flowDelegate?.navigate(step: .articleCategoryTappedFromArticleCategories(resource: resource, language: language, category: category, manifest: manifest))
    }
    
    func pullToRefresh() {
                
        pullToRefreshArticlesTask = Task {
            
            try await pullToRefreshArticlesUseCase
                .execute(
                    translation: translation,
                    language: language,
                    manifest: manifest
                )
        }
    }
}
