//
//  ToolLanguageDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class ToolLanguageDownloader {
    
    private let cache: ToolLanguageDownloadCache
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let toolDownloader: ToolDownloader
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    
    init(cache: ToolLanguageDownloadCache, resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, toolDownloader: ToolDownloader, downloadedLanguagesRepository: DownloadedLanguagesRepository) {
     
        self.cache = cache
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.toolDownloader = toolDownloader
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
    }
    
    @MainActor func observeCollectionChanges() -> AnyPublisher<Void, Error> {
        return cache.persistence
            .observeCollectionChangesPublisher()
    }
    
    func getToolLanguageDownload(languageId: String) throws -> ToolLanguageDownloadDataModel? {
        return try cache.persistence.getDataModel(id: languageId)
    }
    
    func downloadToolLanguage(languageId: String) async throws {
        
        guard let languageModel = try languagesRepository.getLanguage(id: languageId) else {
            
            throw NSError.errorWithDomain(
                domain: "ToolLanguageDownloader",
                code: -1,
                description: "Internal Error in ToolLanguageDownloader.  Failed to fetch language with language id: \(languageId)"
            )
        }
        
        let downloadDataModel = ToolLanguageDownloadDataModel(
            id: languageId,
            languageId: languageId,
            downloadErrorDescription: nil,
            downloadErrorHttpStatusCode: nil,
            downloadProgress: 0,
            downloadStartedAt: Date()
        )
        
        _ = try await cache
            .persistence
            .writeObjectsAsync(
                externalObjects: [downloadDataModel],
                writeOption: nil,
                getOption: nil
            )
        
        do {
            
            let includeToolTypes: [ResourceType] = ResourceType.toolTypes + [.lesson]
            
            let tools: [ResourceDataModel] = try resourcesRepository.getCachedResourcesByFilter(
                filter: ResourcesFilter(category: nil, languageModelCode: languageModel.code, resourceTypes: includeToolTypes)
            )
            
            let downloadTools: [DownloadToolData] = tools.map({
                DownloadToolData(toolId: $0.id, languages: [languageModel.code])
            })
            
            if try downloadedLanguagesRepository.getDownloadedLanguage(languageId: languageId) == nil {
                
                _ = try await downloadedLanguagesRepository
                    .storeDownloadedLanguage(
                        languageId: languageId,
                        downloadComplete: false
                    )
            }
            
            try await toolDownloader.downloadToolsWithProgressClosure(tools: downloadTools, requestPriority: .low, onProgress: { (progress: Double) in
                
                Task {
                    
                    let progressDataModel = downloadDataModel.copy(
                        downloadProgress: progress
                    )
                    
                    _ = try await cache
                        .persistence
                        .writeObjectsAsync(
                            externalObjects: [progressDataModel],
                            writeOption: nil,
                            getOption: nil
                        )
                }
                
            }, onComplete: {
                
                Task {
                    
                    let progressDataModel = downloadDataModel.copy(
                        downloadProgress: 1
                    )
                    
                    _ = try await cache
                        .persistence
                        .writeObjectsAsync(
                            externalObjects: [progressDataModel],
                            writeOption: nil,
                            getOption: nil
                        )
                    
                    
                    _ = try await downloadedLanguagesRepository
                        .storeDownloadedLanguage(
                            languageId: languageId,
                            downloadComplete: true
                        )
                }
            })
        }
        catch let error {
            
            let errorDataModel = downloadDataModel.copy(
                downloadErrorDescription: error.localizedDescription
            )
            
            _ = try await cache
                .persistence
                .writeObjectsAsync(
                    externalObjects: [errorDataModel],
                    writeOption: nil,
                    getOption: nil
                )
                        
            try downloadedLanguagesRepository.deleteDownloadedLanguage(
                languageId: languageId
            )
            
            throw error
        }
    }
    
    func syncDownloadedLanguages() async throws {
        
        _ = try await downloadedLanguagesRepository.markAllDownloadsAsCompleted()
        
        let downloadedLanguages: [DownloadedLanguageDataModel] = try await downloadedLanguagesRepository.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: true
        )
        
        for language in downloadedLanguages {
            
            _ = try await downloadToolLanguage(languageId: language.languageId)
        }
    }
}
