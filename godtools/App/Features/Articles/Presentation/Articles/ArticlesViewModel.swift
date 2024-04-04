//
//  ArticlesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ArticlesViewModel: NSObject {
    
    typealias AemUri = String
    
    private let resource: ResourceModel
    private let language: LanguageDomainModel
    private let category: GodToolsToolParser.Category
    private let manifest: Manifest
    private let articleManifestAemRepository: ArticleManifestAemRepository
    private let localizationServices: LocalizationServices
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
        
    private var articleAemCacheObjects: [ArticleAemCacheObject] = Array()
    private var continueArticleDownloadReceipt: ArticleManifestDownloadArticlesReceipt?
    private var downloadArticlesReceipt: ArticleManifestDownloadArticlesReceipt?
    
    private weak var flowDelegate: FlowDelegate?
    
    let navTitle: ObservableValue<String> = ObservableValue(value: "")
    let numberOfArticles: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let errorMessage: ObservableValue<ArticlesErrorMessageViewModel?> = ObservableValue(value: nil)
        
    init(flowDelegate: FlowDelegate, resource: ResourceModel, language: LanguageDomainModel, category: GodToolsToolParser.Category, manifest: Manifest, articleManifestAemRepository: ArticleManifestAemRepository, localizationServices: LocalizationServices, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, currentArticleDownloadReceipt: ArticleManifestDownloadArticlesReceipt?) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.language = language
        self.category = category
        self.manifest = manifest
        self.articleManifestAemRepository = articleManifestAemRepository
        self.localizationServices = localizationServices
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.continueArticleDownloadReceipt = currentArticleDownloadReceipt
        
        super.init()
                        
        navTitle.accept(value: category.label?.text ?? "")

        let cachedArticleAemUris: [AemUri] = getCachedArticleAemUris()
        
        reloadArticlesFromCache(aemUris: cachedArticleAemUris, completionOnMainThread: { [weak self] in
            
            if let continueArticleDownloadReceipt = self?.continueArticleDownloadReceipt {
                self?.continueArticlesDownload(downloadArticlesReceipt: continueArticleDownloadReceipt)
            }
            else if cachedArticleAemUris.isEmpty {
                self?.downloadArticles(forceDownload: true)
            }
        })
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        continueArticleDownloadReceipt?.removeAllObserversFrom(object: self)
        downloadArticlesReceipt?.cancel()
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
    
    private var shouldShowLoadingIndicator: Bool {
        return numberOfArticles.value == 0
    }
    
    private func continueArticlesDownload(downloadArticlesReceipt: ArticleManifestDownloadArticlesReceipt) {
        
        if shouldShowLoadingIndicator {
            isLoading.accept(value: true)
        }
        
        downloadArticlesReceipt.completed.addObserver(self) { [weak self] (result: ArticleAemRepositoryResult?) in
            
            guard let weakSelf = self else {
                return
            }
            
            guard let result = result else {
                return
            }
            
            DispatchQueue.main.async {
                self?.continueArticleDownloadReceipt?.removeAllObserversFrom(object: weakSelf)
                self?.handleCompleteArticlesDownload(result: result)
            }
        }
    }
    
    private func downloadArticles(forceDownload: Bool) {
        
        if downloadArticlesReceipt != nil {
            return
        }
        
        if shouldShowLoadingIndicator {
            isLoading.accept(value: true)
        }
        
        errorMessage.accept(value: nil)
        
        downloadArticlesReceipt = articleManifestAemRepository.downloadAndCacheManifestAemUrisReceipt(manifest: manifest, languageCode: language.localeIdentifier, forceDownload: forceDownload) { [weak self] (result: ArticleAemRepositoryResult) in
            self?.downloadArticlesReceipt = nil
            DispatchQueue.main.async { [weak self] in
                self?.handleCompleteArticlesDownload(result: result)
            }
        }
    }
    
    private func handleCompleteArticlesDownload(result: ArticleAemRepositoryResult) {
                
        isLoading.accept(value: false)
        
        let cachedArticleAemUris: [AemUri] = getCachedArticleAemUris()
        
        reloadArticlesFromCache(aemUris: cachedArticleAemUris, completionOnMainThread: { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            if let downloadError = result.downloaderResult.downloadError, cachedArticleAemUris.isEmpty {
                
                let downloadArticlesErrorViewModel = DownloadArticlesErrorViewModel(
                    localizationServices: weakSelf.localizationServices,
                    error: downloadError
                )
                
                let errorViewModel = ArticlesErrorMessageViewModel(
                    localizationServices: weakSelf.localizationServices,
                    message: downloadArticlesErrorViewModel.message
                )
                
                weakSelf.errorMessage.accept(value: errorViewModel)
            }
            else {
                weakSelf.errorMessage.accept(value: nil)
            }
        })
    }
    
    private func getCachedArticleAemUris() -> [AemUri] {
        
        guard let categoryId = category.id else {
            return []
        }
        
        let languageCode: String = language.localeIdentifier
        
        let categoryArticles: [CategoryArticleModel] = articleManifestAemRepository.getCategoryArticles(
            categoryId: categoryId,
            languageCode: languageCode
        )
        
        var aemUris: Set<String> = Set()
        
        for article in categoryArticles {
            for uri in article.aemUris {
                aemUris.insert(uri)
            }
        }
        
        return aemUris.sorted()
    }
    
    private func reloadArticlesFromCache(aemUris: [AemUri], completionOnMainThread: @escaping (() -> Void)) {
        
        articleManifestAemRepository.getAemCacheObjectsOnBackgroundThread(aemUris: aemUris) { [weak self] (aemCacheObjects: [ArticleAemCacheObject]) in
            
            let sortedAemCacheObjects: [ArticleAemCacheObject] = aemCacheObjects.sorted(by: {
                let thisTitle: String? = $0.aemData.articleJcrContent?.title
                let thatTitle: String? = $1.aemData.articleJcrContent?.title
                
                if let thisTitle = thisTitle, let thatTitle = thatTitle {
                    return thisTitle < thatTitle
                }
                
                return false
            })
            
            DispatchQueue.main.async {
                self?.articleAemCacheObjects = sortedAemCacheObjects
                self?.numberOfArticles.accept(value: sortedAemCacheObjects.count)
                completionOnMainThread()
            }
        }
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
        downloadArticles(forceDownload: true)
    }
}
