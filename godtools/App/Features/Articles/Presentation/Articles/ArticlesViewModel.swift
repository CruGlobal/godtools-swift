//
//  ArticlesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import Combine
import LocalizationServices

class ArticlesViewModel: NSObject {
    
    private static var downloadArticlesCancellable: AnyCancellable?
    
    typealias AemUri = String
    
    private let resource: ResourceModel
    private let language: LanguageModel
    private let category: GodToolsToolParser.Category
    private let manifest: Manifest
    private let articleManifestAemRepository: ArticleManifestAemRepository
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let localizationServices: LocalizationServices
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
        
    private var articleAemCacheObjects: [ArticleAemCacheObject] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let numberOfArticles: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessageViewModel?> = ObservableValue(value: nil)
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel, language: LanguageModel, category: GodToolsToolParser.Category, manifest: Manifest, articleManifestAemRepository: ArticleManifestAemRepository, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, localizationServices: LocalizationServices, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.language = language
        self.category = category
        self.manifest = manifest
        self.articleManifestAemRepository = articleManifestAemRepository
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.localizationServices = localizationServices
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        super.init()
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
                        
        navTitle.accept(value: category.label?.text ?? "")
        
        articleManifestAemRepository
            .observeArticleAemCacheObjectsChangedPublisher()
            .flatMap { (onChange: Void) -> AnyPublisher<[AemUri], Never> in
                
                guard let categoryId = category.id else {
                    return Just([])
                        .eraseToAnyPublisher()
                }
                
                return articleManifestAemRepository
                    .getCategoryArticlesPublisher(
                        categoryId: categoryId,
                        languageCode: language.localeId
                    )
                    .map { (categoryArticles: [CategoryArticleModel]) in
                        
                        var uniqueAemUris: Set<String> = Set()
                        
                        for article in categoryArticles {
                            for uri in article.aemUris {
                                uniqueAemUris.insert(uri)
                            }
                        }
                        
                        return uniqueAemUris.sorted()
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { (aemUris: [String]) -> AnyPublisher<[ArticleAemCacheObject], Never> in
                
                return articleManifestAemRepository.getAemCacheObjectsPublisher(aemUris: aemUris)
                    .map { (aemCacheObjects: [ArticleAemCacheObject]) in
                        
                        let sortedAemCacheObjects: [ArticleAemCacheObject] = aemCacheObjects.sorted(by: {
                            let thisTitle: String? = $0.aemData.articleJcrContent?.title
                            let thatTitle: String? = $1.aemData.articleJcrContent?.title
                            
                            if let thisTitle = thisTitle, let thatTitle = thatTitle {
                                return thisTitle < thatTitle
                            }
                            
                            return false
                        })
                        
                        return sortedAemCacheObjects
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (aemCacheObjects: [ArticleAemCacheObject]) in
                
                self?.isLoading.accept(value: false)
                self?.articleAemCacheObjects = aemCacheObjects
                self?.numberOfArticles.accept(value: aemCacheObjects.count)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return "Category : \(category.label?.text ?? "")"
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return "articles-list"
    }
    
    private func cancelArticleDownload() {
        Self.downloadArticlesCancellable?.cancel()
        Self.downloadArticlesCancellable = nil
    }
    
    private func downloadArticles(downloadCachePolicy: ArticleAemDownloaderCachePolicy) {
                
        cancelArticleDownload()
        
        isLoading.accept(value: true)
        
        Self.downloadArticlesCancellable = articleManifestAemRepository
            .downloadAndCacheManifestAemUrisPublisher(
                manifest: manifest,
                languageCode: language.localeId,
                downloadCachePolicy: .ignoreCache,
                sendRequestPriority: .high
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (result: ArticleAemRepositoryResult) in
                
                self?.isLoading.accept(value: false)
            })
    }
    
    // TODO: Implement error handling?  GT-2580 ~Levi
//    private func handleCompleteArticlesDownload(appLanguage: AppLanguageDomainModel, result: ArticleAemRepositoryResult) {
//                
//        isLoading.accept(value: false)
//        
//        let cachedArticleAemUris: [AemUri] = getCachedArticleAemUris()
//        
//        reloadArticlesFromCache(aemUris: cachedArticleAemUris, completionOnMainThread: { [weak self] in
//            
//            guard let weakSelf = self else {
//                return
//            }
//            
//            if let downloadError = result.downloaderResult.downloadError, cachedArticleAemUris.isEmpty {
//                
//                let downloadArticlesErrorViewModel = DownloadArticlesErrorViewModel(
//                    appLanguage: appLanguage,
//                    localizationServices: weakSelf.localizationServices,
//                    error: downloadError
//                )
//                
//                let errorViewModel = ArticlesErrorMessageViewModel(
//                    appLanguage: appLanguage,
//                    localizationServices: weakSelf.localizationServices,
//                    message: downloadArticlesErrorViewModel.message
//                )
//                
//                weakSelf.errorMessage.accept(value: errorViewModel)
//            }
//            else {
//                weakSelf.errorMessage.accept(value: nil)
//            }
//        })
//    }
}

// MARK: - Inputs

extension ArticlesViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromArticles)
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
    
    func articleTapped(index: Int) {
        
        let aemCacheObject: ArticleAemCacheObject = articleAemCacheObjects[index]
        
        flowDelegate?.navigate(step: .articleTappedFromArticles(resource: resource, aemCacheObject: aemCacheObject))
    }
    
    func articleWillAppear(index: Int) -> ArticleCellViewModel {
        
        let aemCacheObject: ArticleAemCacheObject = articleAemCacheObjects[index]
        
        return ArticleCellViewModel(aemData: aemCacheObject.aemData)
    }
    
    func downloadArticlesTapped() {
        
        downloadArticles(downloadCachePolicy: .ignoreCache)
    }
}
