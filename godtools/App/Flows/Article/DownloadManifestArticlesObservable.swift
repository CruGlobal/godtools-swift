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
    
    private let translation: TranslationModel
    private let language: LanguageModel
    private let manifest: Manifest
    private let articleManifestAemRepository: ArticleManifestAemRepository
    
    private var downloadArticlesCancellable: AnyCancellable?
    
    @Published private(set) var articleAemRepositoryResult: ArticleAemRepositoryResult = ArticleAemRepositoryResult.emptyResult()
    @Published private(set) var isDownloading: Bool = false
    
    init(translation: TranslationModel, language: LanguageModel, manifest: Manifest, articleManifestAemRepository: ArticleManifestAemRepository) {
        
        self.translation = translation
        self.language = language
        self.manifest = manifest
        self.articleManifestAemRepository = articleManifestAemRepository
    }
    
    func cancelDownload() {

        downloadArticlesCancellable?.cancel()
        downloadArticlesCancellable = nil
    }
    
    func downloadArticles(downloadCachePolicy: ArticleAemDownloaderCachePolicy, forceFetchFromRemote: Bool) {
                
        cancelDownload()
        
        isDownloading = true
        
        downloadArticlesCancellable = articleManifestAemRepository
            .downloadAndCacheManifestAemUrisPublisher(
                manifest: manifest,
                translationId: translation.id,
                languageCode: language.localeId,
                downloadCachePolicy: downloadCachePolicy,
                sendRequestPriority: .high,
                forceFetchFromRemote: forceFetchFromRemote
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (articleAemRepositoryResult: ArticleAemRepositoryResult) in
                
                guard let weakSelf = self else {
                    return
                }
                
                let articleDownloadCancelled: Bool = articleAemRepositoryResult.downloaderResult.downloadError == .cancelled
                let articleDownloadRunning: Bool = weakSelf.downloadArticlesCancellable != nil
                
                if articleDownloadCancelled && articleDownloadRunning {
                    weakSelf.isDownloading = true
                }
                else {
                    weakSelf.isDownloading = false
                }
                
                weakSelf.articleAemRepositoryResult = articleAemRepositoryResult
            })
    }
}
