//
//  ArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class ArticleViewModel: ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let stepEmitter: FlowStepEmitter
    private let flowType: ArticleWebViewModelFlowType
    private let articleId: String
    private let article: ArticleDomainModel
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let displayArticleAfterNumberOfSeconds: TimeInterval = 2
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var loadingArticle: ArticleDomainModel?
    @Published private(set) var navTitle: String = ""
    @Published private(set) var hidesShareButton: Bool = false
    @Published private(set) var hidesDebugButton: Bool = true
    
    init(
        stepEmitter: FlowStepEmitter,
        flowType: ArticleWebViewModelFlowType,
        articleId: String,
        article: ArticleDomainModel,
        incrementUserCounterUseCase: IncrementUserCounterUseCase,
        getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.flowType = flowType
        self.articleId = articleId
        self.article = article
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.getAppUIDebuggingIsEnabledUseCase = getAppUIDebuggingIsEnabledUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        navTitle = article.title
        hidesShareButton = !article.isShareable
        hidesDebugButton = !getAppUIDebuggingIsEnabledUseCase.execute()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return "Article : \(article.title)"
    }
    
    private var analyticsSiteSection: String {
        let siteSection: String
        
        switch flowType {
        
        case .deeplink:
            siteSection = "articles"
        
        case .tool(let resource):
            siteSection = resource.abbreviation
        }
        
        return siteSection
    }
    
    private var analyticsSiteSubSection: String {
        return "article"
    }
}

// MARK: - Inputs

extension ArticleViewModel {
    
    @objc func backTapped() {
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromArticle)
    }
    
    @objc func debugTapped() {
        
//        guard let articleUrl = loadingArticle else {
//            return
//        }
//        
//        stepEmitter.emit(step: AppFlowStep.debugTappedFromArticle(articleUrl: articleUrl))
    }
    
    @objc func sharedTapped() {
        stepEmitter.emit(step: AppFlowStep.sharedTappedFromArticle(articleId: articleId))
    }
    
    func pageViewed() {
        
        if loadingArticle == nil {
            loadingArticle = article
        }
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
        
        incrementUserCounterUseCase
            .execute(
                interaction: .articleOpen(uri: articleId)
            )
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &Self.backgroundCancellables)
    }
}
