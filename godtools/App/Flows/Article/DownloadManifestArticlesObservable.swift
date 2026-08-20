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
    
    init(
        translation: TranslationDataModel,
        language: LanguageDataModel,
        manifest: Manifest,
        articleManifestAemRepository: ArticleManifestAemRepository
    ) {
        
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
        
        let manifest: Manifest = self.manifest
        let translationId: String = translation.id
        let languageCode: String = self.language.localeId
        
        downloadArticlesTask = Task { [weak self] in
            
            do {
                
                // TODO: Don't inject Manifest.  Only inject data needed that is Sendable. ~Levi
                
                let download: ArticleAemDownload? = try await self?.articleManifestAemRepository.downloadAndCacheManifestAemUris(
                    manifest: manifest,
                    translationId: translationId,
                    languageCode: languageCode,
                    downloadCachePolicy: downloadCachePolicy,
                    requestPriority: .high,
                    forceFetchFromRemote: forceFetchFromRemote
                )
                
                self?.isDownloading = false
                
                if let error = download?.errors.firstErrorNotConnectedToInternet {
                    self?.downloadResult = .failure(error)
                }
                else {
                    self?.downloadResult = .success(Void())
                }
            }
            catch let error {
             
                self?.isDownloading = false
                
                self?.downloadResult = .failure(error)
            }
        }
    }
}
