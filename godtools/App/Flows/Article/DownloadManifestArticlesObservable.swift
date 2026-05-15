//
//  DownloadManifestArticlesObservable.swift
//  godtools
//
//  Created by Levi Eggert on 5/15/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

@MainActor
final class DownloadManifestArticlesObservable: ObservableObject {
    
    private let translation: TranslationDataModel
    private let language: LanguageDataModel
    private let manifest: Manifest
    private let articleManifestAemRepository: ArticleManifestAemRepository
    
    private var downloadArticlesTask: Task<Void, Error>?
    
    @Published private(set) var downloadResult: Result<Void, Error>?
    @Published private(set) var isDownloading: Bool = false
    
    init(translation: TranslationDataModel, language: LanguageDataModel, manifest: Manifest, articleManifestAemRepository: ArticleManifestAemRepository) {
        
        self.translation = translation
        self.language = language
        self.manifest = manifest
        self.articleManifestAemRepository = articleManifestAemRepository
    }
    
    func cancelDownload() {

        downloadArticlesTask?.cancel()
        downloadArticlesTask = nil
    }
    
    func downloadArticles(downloadCachePolicy: ArticleAemDownloaderCachePolicy, forceFetchFromRemote: Bool) {
                
        cancelDownload()
        
        isDownloading = true
        
        downloadArticlesTask = Task {
            
            do {
                
                let download = try await articleManifestAemRepository.downloadAndCacheManifestAemUris(
                    manifest: manifest,
                    translationId: translation.id,
                    languageCode: language.localeId,
                    downloadCachePolicy: downloadCachePolicy,
                    requestPriority: .high,
                    forceFetchFromRemote: forceFetchFromRemote
                )
                
                isDownloading = false
                
                if let error = download.firstErrorNotConnectedToInternet {
                    downloadResult = .failure(error)
                }
                else {
                    downloadResult = .success(Void())
                }
            }
            catch let error {
             
                isDownloading = false
                
                downloadResult = .failure(error)
            }
        }
    }
}
