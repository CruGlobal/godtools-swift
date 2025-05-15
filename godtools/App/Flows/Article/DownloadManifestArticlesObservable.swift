//
//  DownloadManifestArticlesObservable.swift
//  godtools
//
//  Created by Levi Eggert on 5/15/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

class DownloadManifestArticlesObservable: ObservableObject {
    
    private let language: LanguageModel
    private let manifest: Manifest
    private let articleManifestAemRepository: ArticleManifestAemRepository
    
    private var downloadArticlesCancellable: AnyCancellable?
    
    @Published private(set) var articleAemRepositoryResult: ArticleAemRepositoryResult = ArticleAemRepositoryResult.emptyResult()
    @Published private(set) var isDownloading: Bool = false
    
    init(language: LanguageModel, manifest: Manifest, articleManifestAemRepository: ArticleManifestAemRepository) {
        
        self.language = language
        self.manifest = manifest
        self.articleManifestAemRepository = articleManifestAemRepository
    }
    
    func cancelDownload() {
        downloadArticlesCancellable?.cancel()
        downloadArticlesCancellable = nil
    }
    
    func downloadArticles(downloadCachePolicy: ArticleAemDownloaderCachePolicy) {
        
        cancelDownload()
        
        isDownloading = true
        
        downloadArticlesCancellable = articleManifestAemRepository
            .downloadAndCacheManifestAemUrisPublisher(
                manifest: manifest,
                languageCode: language.localeId,
                downloadCachePolicy: .ignoreCache,
                sendRequestPriority: .high
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (articleAemRepositoryResult: ArticleAemRepositoryResult) in
                
                self?.articleAemRepositoryResult = articleAemRepositoryResult
                self?.isDownloading = false
            })
    }
}
