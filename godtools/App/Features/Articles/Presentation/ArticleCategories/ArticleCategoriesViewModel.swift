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
        
    private let stepEmitter: FlowStepEmitter
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
    
    private var getCategoriesTask: Task<Void, Error>?
        
    @Published private(set) var categories: [ArticleCategoryDomainModel] = Array()
    
    init(
        stepEmitter: FlowStepEmitter,
        resource: ResourceDataModel,
        language: LanguageDataModel,
        translation: TranslationDataModel,
        manifest: Manifest,
        getArticleCategoriesUseCase: GetArticleCategoriesUseCase,
        pullToRefreshArticlesUseCase: PullToRefreshArticlesUseCase,
        incrementUserCounterUseCase: IncrementUserCounterUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.resource = resource
        self.language = language
        self.translation = translation
        self.manifest = manifest
        self.getArticleCategoriesUseCase = getArticleCategoriesUseCase
        self.pullToRefreshArticlesUseCase = pullToRefreshArticlesUseCase
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        loadCategories()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        pullToRefreshArticlesTask?.cancel()
        getCategoriesTask?.cancel()
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
    
    private func loadCategories() {
        
        getCategoriesTask?.cancel()
        
        let sendableCategories = manifest.sendableCategories
        
        getCategoriesTask = Task { [weak self] in
            
            self?.categories = await self?.getArticleCategoriesUseCase.execute(categories: sendableCategories) ?? Array()
        }
    }
}

// MARK: - Inputs

extension ArticleCategoriesViewModel {
    
    @objc func backTapped() {
        stepEmitter.emit(step: AppFlowStep.backTappedFromArticleCategories)
    }
    
    func pageViewed() {
        
        if pageViewCount == 0 {
            
            let incrementUserCounterUseCase: IncrementUserCounterUseCase = self.incrementUserCounterUseCase
            let resourceId: String = resource.id
            
            Task.detached {
                
                _ = try await incrementUserCounterUseCase.execute(interaction: .toolOpen(tool: resourceId))
            }
        }
        
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase = self.trackScreenViewAnalyticsUseCase
        
        Task.detached {
            await trackScreenViewAnalyticsUseCase.execute(
                properties: analyticsProperties
            )
        }
                
        pageViewCount += 1
    }
    
    func categoryTapped(category: ArticleCategoryDomainModel) {
                
        stepEmitter.emit(step: AppFlowStep.articleCategoryTappedFromArticleCategories(resource: resource, language: language, category: category, manifest: manifest))
    }
    
    func pullToRefresh() {
                
        pullToRefreshArticlesTask = Task { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            try await weakSelf.pullToRefreshArticlesUseCase
                .execute(
                    translation: weakSelf.translation,
                    language: weakSelf.language,
                    manifest: weakSelf.manifest
                )
        }
    }
}
