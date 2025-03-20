//
//  ToolLanguageDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ToolLanguageDownloader {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let toolDownloader: ToolDownloader
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    private let cache: RealmToolLanguageDownloaderCache
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, toolDownloader: ToolDownloader, downloadedLanguagesRepository: DownloadedLanguagesRepository, cache: RealmToolLanguageDownloaderCache) {
     
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.toolDownloader = toolDownloader
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.cache = cache
    }
    
    func downloadToolLanguagePublisher(languageId: String) -> AnyPublisher<ToolDownloaderDataModel, Error> {
        
        guard let languageModel = languagesRepository.getLanguage(id: languageId) else {
            
            let error: Error = NSError.errorWithDomain(
                domain: "ToolLanguageDownloader",
                code: -1,
                description: "Internal Error in ToolLanguageDownloader.  Failed to fetch language with language id: \(languageId)"
            )
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        let cache: RealmToolLanguageDownloaderCache = self.cache
        
        let dataModel = ToolLanguageDownload(languageId: languageId, downloadProgress: 0, downloadStartedAt: Date())
                
        cache.storeToolLanguageDownload(dataModel: dataModel)
        
        let includeToolTypes: [ResourceType] = ResourceType.toolTypes + [.lesson]
        
        let tools: [ResourceModel] = resourcesRepository.getCachedResourcesByFilter(
            filter: ResourcesFilter(category: nil, languageModelCode: languageModel.code, resourceTypes: includeToolTypes)
        )
        
        let downloadTools: [DownloadToolDataModel] = tools.map({
            DownloadToolDataModel(toolId: $0.id, languages: [languageModel.code])
        })
                
        return toolDownloader.downloadToolsPublisher(tools: downloadTools)
            .map {
                
                cache.updateDownloadProgress(
                    languageId: languageId,
                    downloadProgress: $0.progress
                )
                
                return $0
            }
            .eraseToAnyPublisher()
    }
    
    func syncDownloadedLanguagesPublisher() -> AnyPublisher<Void, Error> {
        
        downloadedLanguagesRepository.markAllDownloadsAsCompleted()
        
        return downloadedLanguagesRepository.getDownloadedLanguagesPublisher(completedDownloadsOnly: true)
            .flatMap({ (downloadedLanguages: [DownloadedLanguageDataModel]) -> AnyPublisher<Void, Error> in
                                         
                let downloadToolLanguageRequests: [AnyPublisher<ToolDownloaderDataModel, Error>] = downloadedLanguages.map({
                    self.downloadToolLanguagePublisher(languageId: $0.languageId)
                })
                                
                return Publishers.MergeMany(downloadToolLanguageRequests)
                    .map { _ in
                        Void()
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
