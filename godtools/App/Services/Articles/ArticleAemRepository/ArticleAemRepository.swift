//
//  ArticleAemRepository.swift
//  godtools
//
//  Created by Robert Eldredge on 3/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleAemRepository: ArticleAemRepositoryType {
    
    private let importDownloader: ArticleAemImportDownloader
    private let appDiContainer: AppDiContainer
    
    required init(importDownloader: ArticleAemImportDownloader, appDiContainer: AppDiContainer) {
        
        self.importDownloader = importDownloader
        self.appDiContainer = appDiContainer
    }
    
    func getArticleArchiveUrl(filename: String) -> URL? {
        return importDownloader.getWebArchiveUrl(location: ArticleAemWebArchiveFileCacheLocation(filename: filename))
    }
    
    func getArticleAem(aemUri: ArticleAemUri, cache: ((_ articleAem: ArticleAemModel) -> Void), downloadStarted: (() -> Void), downloadFinished: ((_ result: Result<ArticleAemModel, Error>) -> Void)) {
        
        //TODO: create ArticleAemArchiver and ArticleAemDownloader to replace ArticleAemImportDownloader ~Robert
        // If the article aem is cached to the filesystem, go ahead and call the cache closure and return immediately.

        // Otherwise, we will download and parse the aem uri and cache the web archive to the filesystem.
        appDiContainer.translationsFileCache.getTranslationManifest(translationId: "en-US") { (result: Result<TranslationManifestData, TranslationsFileCacheError>) in
            
            switch result {
            
            case .success(let translationManifestData):
                let translationZipFile = translationManifestData.translationZipFile
                
                let receipt = importDownloader.downloadAndCache(translationZipFile: translationZipFile, aemImportSrcs: [aemUri.uriString])
                
                receipt?.started.addObserver(self) { [weak self] (isStarted: Bool) in
                    if isStarted {
                        
                    }
                }
                
                receipt?.completed.addObserver(self) { [weak self] (isComplete: Bool) in
                    if isComplete {
                        
                    }
                }
                
            case .failure(let error):
                break
                
            }
        }
        
    }
}
