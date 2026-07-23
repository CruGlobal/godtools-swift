//
//  ArticlesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsShared

@MainActor
final class ArticlesViewModel: ObservableObject {
    
    typealias AemUri = String
    
    private let stepEmitter: FlowStepEmitter
    private let resource: ResourceDataModel
    private let language: LanguageDataModel
    private let category: ArticleCategoryDomainModel
    private let manifest: Manifest
    private let downloadArticlesObservable: DownloadManifestArticlesObservable
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getArticlesUseCase: GetArticlesUseCase
    private let localizationServices: LocalizationServicesInterface
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    private var getArticlesTask: Task<Void, Error>?
    private var cancellables: Set<AnyCancellable> = Set()
        
    let navTitle: String
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var articles: [ArticleListItemDomainModel] = Array()
    @Published private(set) var articlesError: ArticlesErrorDomainModel?
    
    init(
        stepEmitter: FlowStepEmitter,
        resource: ResourceDataModel,
        language: LanguageDataModel,
        category: ArticleCategoryDomainModel,
        manifest: Manifest,
        downloadArticlesObservable: DownloadManifestArticlesObservable,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getArticlesUseCase: GetArticlesUseCase,
        localizationServices: LocalizationServicesInterface,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.resource = resource
        self.language = language
        self.category = category
        self.manifest = manifest
        self.downloadArticlesObservable = downloadArticlesObservable
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getArticlesUseCase = getArticlesUseCase
        self.localizationServices = localizationServices
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        navTitle = category.title
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        downloadArticlesObservable
            .$isDownloading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isDownloading: Bool) in

                self?.isLoading = isDownloading
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $appLanguage.dropFirst(),
            downloadArticlesObservable.$downloadResult,
            $articles.dropFirst()
        )
        .map { (appLanguage: AppLanguageDomainModel, downloadResult: Result<Void, Error>?, articles: [ArticleListItemDomainModel]) in
            
            let downloadError: Error?
            
            if let downloadResult = downloadResult {
                switch downloadResult {
                case .success( _):
                    downloadError = nil
                case .failure(let error):
                    downloadError = error
                }
            }
            else {
                downloadError = nil
            }
            
            let noArticles: Bool = articles.isEmpty
            
            if let downloadError = downloadError, noArticles {
                
                let downloadArticlesErrorViewModel = DownloadArticlesErrorViewModel(
                    appLanguage: appLanguage,
                    localizationServices: localizationServices,
                    error: downloadError
                )
                
                let title: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.downloadError.key)
                let message: String = downloadArticlesErrorViewModel.message
                let downloadActionTitle: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.articlesRetryDownloadButtonTitle.key)
                
                return ArticlesErrorDomainModel(
                    title: title,
                    message: message,
                    downloadActionTitle: downloadActionTitle
                )
            }
            else {
                
                return nil
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (error: ArticlesErrorDomainModel?) in
            
            self?.articlesError = error
        }
        .store(in: &cancellables)
        
        downloadArticlesObservable
            .$downloadResult
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] _ in
                
                self?.didDownloadArticles()
            })
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        getArticlesTask?.cancel()
    }
    
    private var analyticsScreenName: String {
        return "Category : \(category.title)"
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return "articles-list"
    }
    
    private func didDownloadArticles() {
        
        getArticlesTask?.cancel()
        
        getArticlesTask = Task {
            
            articles = try await getArticlesUseCase.execute(
                category: category,
                languageCode: language.localeId
            )
        }
    }
}

// MARK: - Inputs

extension ArticlesViewModel {
    
    @objc func backTapped() {
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromArticles)
    }
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: appLanguage,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    func articleTapped(article: ArticleListItemDomainModel) {
          
        stepEmitter.emit(step: AppFlowStep.articleTappedFromArticles(resource: resource, articleId: article.id))
    }
    
    func downloadArticlesTapped() {
        
        downloadArticlesObservable.downloadArticles(downloadCachePolicy: .ignoreCache, forceFetchFromRemote: true)
    }
    
    func pullToRefresh() {
                
        downloadArticlesObservable.downloadArticles(downloadCachePolicy: .ignoreCache, forceFetchFromRemote: true)
    }
}
