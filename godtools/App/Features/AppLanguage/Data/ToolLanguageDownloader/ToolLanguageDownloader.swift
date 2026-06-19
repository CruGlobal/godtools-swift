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
    private let downloadedLanguagesCache: DownloadedLanguagesCache
    
    init(
        cache: ToolLanguageDownloadCache,
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        toolDownloader: ToolDownloader,
        downloadedLanguagesCache: DownloadedLanguagesCache
    ) {
     
        self.cache = cache
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.toolDownloader = toolDownloader
        self.downloadedLanguagesCache = downloadedLanguagesCache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache.persistence
            .observeCollectionChangesPublisher()
    }
    
    private func markAllDownloadsAsCompleted() async throws {
        
        let incompleteDownloads: [ToolLanguageDownloadDataModel] = try await cache.getDownloads(state: .incomplete)
        
        var downloadsToUpdate: [ToolLanguageDownloadDataModel] = Array()
        
        for download in incompleteDownloads {
            
            downloadsToUpdate.append(
                download.copy(downloadProgress: 1)
            )
        }
        
        try await cache.persistence.writeObjects(externalObjects: downloadsToUpdate)
    }
    
    func getToolLanguageDownload(languageId: String) throws -> ToolLanguageDownloadDataModel? {
        return try cache.persistence.getDataModel(id: languageId)
    }
    
    func deleteToolLanguageDownload(languageId: String) async throws {
        
        _ = try await cache.persistence.deleteObjectsByIds(ids: [languageId], getOption: nil)
    }
    
    func getDownloads(state: ToolLanguageDownloadCache.DownloadState) async throws -> [ToolLanguageDownloadDataModel] {
        
        return try await cache.getDownloads(state: state)
    }
    
    func downloadToolLanguage(languageId: String) async throws {
        
        guard let languageModel = languagesRepository.getLanguageById(id: languageId) else {
            
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
            .writeObjects(
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
            
            if try getToolLanguageDownload(languageId: languageId) == nil {
                
                _ = try await cache.persistence.writeObjects(externalObjects: [downloadDataModel])
            }
            
            try await toolDownloader.downloadToolsWithProgressClosure(tools: downloadTools, requestPriority: .low, onProgress: { (progress: Double) in
                
                Task {
                    
                    let progressDataModel = downloadDataModel.copy(
                        downloadProgress: progress
                    )
                    
                    _ = try await cache
                        .persistence
                        .writeObjects(
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
                        .writeObjects(
                            externalObjects: [progressDataModel],
                            writeOption: nil,
                            getOption: nil
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
                .writeObjects(
                    externalObjects: [errorDataModel],
                    writeOption: nil,
                    getOption: nil
                )
            
            throw error
        }
    }
    
    func syncDownloadedLanguages() async throws {
        
        _ = try await migrateDownloadedLanguagesIfNeeded()
        
        _ = try await markAllDownloadsAsCompleted()
        
        let downloads: [ToolLanguageDownloadDataModel] = try await cache.getDownloads(state: .all)
        
        for download in downloads {
            
            try await self.downloadToolLanguage(languageId: download.languageId)
        }
    }
    
    private func migrateDownloadedLanguagesIfNeeded() async throws {
        
        let completedDownloads = try await downloadedLanguagesCache.getCompletedDownloads()
        
        guard completedDownloads.count > 0 else {
            return
        }
        
        var toolLanguagesToUpdate: [ToolLanguageDownloadDataModel] = Array()
        
        for completedDownload in completedDownloads {
            
            toolLanguagesToUpdate.append(
                ToolLanguageDownloadDataModel(
                    id: completedDownload.id,
                    languageId: completedDownload.languageId,
                    downloadErrorDescription: nil,
                    downloadErrorHttpStatusCode: nil,
                    downloadProgress: 1,
                    downloadStartedAt: completedDownload.createdAt
                )
            )
        }
        
        _ = try await cache.persistence.writeObjects(externalObjects: toolLanguagesToUpdate)
        
        let ids: [String] = completedDownloads.map { $0.id }
        
        _ = try await downloadedLanguagesCache.realmPersistence.deleteObjectsByIds(ids: Set(ids), getOption: nil)
    }
}
