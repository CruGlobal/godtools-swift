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
    
    enum FlowType {
        case deeplink
        case tool(resource: ResourceDataModel)
    }
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let stepEmitter: FlowStepEmitter
    private let flowType: FlowType
    private let articleId: String
    private let article: ArticleDomainModel
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let getDownloadArticlesErrorMessage: GetDownloadArticlesErrorMessage
    private let localizationServices: LocalizationServicesInterface
    private let displayArticleAfterNumberOfSeconds: TimeInterval = 2
    
    private var loadedArticleUrl: URL?
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var navTitle: String = ""
    @Published private(set) var hidesShareButton: Bool = false
    @Published private(set) var hidesDebugButton: Bool = true
    @Published private(set) var loadArticleRequestUrl: URL?
    @Published private(set) var loadArticleError: ArticlesErrorDomainModel?
    
    init(
        stepEmitter: FlowStepEmitter,
        flowType: FlowType,
        articleId: String,
        article: ArticleDomainModel,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        incrementUserCounterUseCase: IncrementUserCounterUseCase,
        getAppUIDebuggingIsEnabledUseCase: GetAppUIDebuggingIsEnabledUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        getDownloadArticlesErrorMessage: GetDownloadArticlesErrorMessage,
        localizationServices: LocalizationServicesInterface
    ) {
        
        self.stepEmitter = stepEmitter
        self.flowType = flowType
        self.articleId = articleId
        self.article = article
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.getAppUIDebuggingIsEnabledUseCase = getAppUIDebuggingIsEnabledUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.localizationServices = localizationServices
        self.getDownloadArticlesErrorMessage = getDownloadArticlesErrorMessage
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        navTitle = article.title
        hidesShareButton = !article.isShareable
        hidesDebugButton = !getAppUIDebuggingIsEnabledUseCase.execute()
        
        downloadArticle()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    var fallbackFileUrl: URL? {
        return article.archiveUrl?.url
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
    
    private var articleUrl: ArticleUrlDomainModel? {
        
        guard let loadedArticleUrl = self.loadedArticleUrl else {
            return nil
        }
        
        if let httpsArticle = article.httpsUrl, loadedArticleUrl == httpsArticle.url {
            return httpsArticle
        }
        else if let archiveArticle = article.archiveUrl, loadedArticleUrl == archiveArticle.url {
            return archiveArticle
        }
        
        return nil
    }
    
    private func getArticleErrorMessage(error: Error) async -> ArticlesErrorDomainModel {
        
        let title: String = await localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: appLanguage,
            key: LocalizableStringKeys.downloadError.key
        )
        
        let message: String = await getDownloadArticlesErrorMessage.getErrorMessage(
            appLanguage: appLanguage,
            error: error
        )
        
        let downloadActionTitle: String = await localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: appLanguage,
            key: LocalizableStringKeys.articlesRetryDownloadButtonTitle.key
        )
        
        return ArticlesErrorDomainModel(title: title, message: message, downloadActionTitle: downloadActionTitle)
    }
    
    private func downloadArticle() {
        
        loadArticleRequestUrl = nil
        loadArticleError = nil
        loadArticleRequestUrl = article.httpsUrl?.url
    }
}

// MARK: - Inputs

extension ArticleViewModel {
    
    @objc func backTapped() {
        stepEmitter.emit(step: AppFlowStep.backTappedFromArticle)
    }
    
    @objc func debugTapped() {
        
        guard let articleUrl = self.articleUrl else {
            return
        }
                
        stepEmitter.emit(step: AppFlowStep.debugTappedFromArticle(articleUrl: articleUrl))
    }
    
    @objc func sharedTapped() {
        stepEmitter.emit(step: AppFlowStep.sharedTappedFromArticle(articleId: articleId))
    }
    
    func pageViewed() {
        
        Task {
            await trackScreenViewAnalyticsUseCase.trackScreen(
                properties: AnalyticsProperties(
                    screenName: analyticsScreenName,
                    siteSection: analyticsSiteSection,
                    siteSubSection: analyticsSiteSubSection,
                    appLanguage: nil,
                    contentLanguage: nil,
                    secondaryContentLanguage: nil
                )
            )
        }
        
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
    
    func downloadArticleTapped() {
        
        downloadArticle()
    }
    
    func didLoadArticle(url: URL?, error: Error?) {

        loadedArticleUrl = url

        if let error = error {

            Task {

                loadArticleError = await getArticleErrorMessage(error: error)
            }
        }
        else {
            loadArticleError = nil
        }
    }
}
