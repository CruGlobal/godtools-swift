//
//  ArticlesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import Combine

@MainActor class ArticlesViewModel: NSObject {
        
    typealias AemUri = String
    
    private let resource: ResourceDataModel
    private let language: LanguageDataModel
    private let category: GodToolsShared.Category
    private let manifest: Manifest
    private let downloadArticlesObservable: DownloadManifestArticlesObservable
    private let articleManifestAemRepository: ArticleManifestAemRepository
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let localizationServices: LocalizationServicesInterface
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
        
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let numberOfArticles: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessageViewModel?> = ObservableValue(value: nil)
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var articleAemCacheObjects: [ArticleAemCacheObject] = Array()
    
    init(flowDelegate: FlowDelegate, resource: ResourceDataModel, language: LanguageDataModel, category: GodToolsShared.Category, manifest: Manifest, downloadArticlesObservable: DownloadManifestArticlesObservable, articleManifestAemRepository: ArticleManifestAemRepository, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, localizationServices: LocalizationServicesInterface, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.language = language
        self.category = category
        self.manifest = manifest
        self.downloadArticlesObservable = downloadArticlesObservable
        self.articleManifestAemRepository = articleManifestAemRepository
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.localizationServices = localizationServices
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        super.init()
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
                        
        navTitle.accept(value: category.label?.text ?? "")
        
        downloadArticlesObservable
            .$isDownloading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isDownloading: Bool) in

                self?.isLoading.accept(value: isDownloading)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $appLanguage.dropFirst(),
            downloadArticlesObservable.$articleAemRepositoryResult,
            $articleAemCacheObjects.dropFirst()
        )
        .map { (appLanguage: AppLanguageDomainModel, result: ArticleAemRepositoryResult, articleAemCacheObjects: [ArticleAemCacheObject]) in
            
            let downloadError: ArticleAemDownloaderError? = result.downloaderResult.downloadError
            let noCachedResults: Bool = articleAemCacheObjects.isEmpty
            
            if let downloadError = downloadError, noCachedResults {
                
                let downloadArticlesErrorViewModel = DownloadArticlesErrorViewModel(
                    appLanguage: appLanguage,
                    localizationServices: localizationServices,
                    error: downloadError
                )
                
                let errorViewModel = ArticlesErrorMessageViewModel(
                    appLanguage: appLanguage,
                    localizationServices: localizationServices,
                    message: downloadArticlesErrorViewModel.message
                )
                
                return errorViewModel
            }
            else {
                
                return nil
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (errorViewModel: ArticlesErrorMessageViewModel?) in
            
            self?.errorMessage.accept(value: errorViewModel)
        }
        .store(in: &cancellables)
        
        downloadArticlesObservable
            .$articleAemRepositoryResult
            .flatMap { (articleAemRepositoryResult: ArticleAemRepositoryResult) -> AnyPublisher<[AemUri], Never> in
                
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
        
        downloadArticlesObservable.downloadArticles(downloadCachePolicy: .ignoreCache, forceFetchFromRemote: true)
    }
}
