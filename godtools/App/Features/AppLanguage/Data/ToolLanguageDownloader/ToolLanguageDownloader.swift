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
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let toolDownloader: ToolDownloader
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
        
    init(
        resourcesRepository: ResourcesRepository,
        languagesRepository: LanguagesRepository,
        toolDownloader: ToolDownloader,
        downloadedLanguagesRepository: DownloadedLanguagesRepository
    ) {
     
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.toolDownloader = toolDownloader
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
    }

    func getToolsToDownloadForLanguage(languageId: String) throws -> [DownloadToolData] {
        
        guard let language = languagesRepository.getLanguageById(id: languageId) else {
            return Array()
        }
        
        let includeToolTypes: [ResourceType] = ResourceType.toolTypes + [.lesson]
        
        let tools: [ResourceDataModel] = try resourcesRepository.getCachedResourcesByFilter(
            filter: ResourcesFilter(category: nil, languageModelCode: language.code, resourceTypes: includeToolTypes)
        )
        
        return tools.map{
            DownloadToolData(toolId: $0.id, languages: [language.code])
        }
    }
    
    @MainActor
    func downloadToolLanguagePublisher(languageId: String) -> AnyPublisher<Double, Error> {
        
        do {
            
            let downloadTools: [DownloadToolData] = try getToolsToDownloadForLanguage(languageId: languageId)
            
            guard !downloadTools.isEmpty else {
                let error: Error = NSError.errorWithDescription(description: "Download tool language failed.  Not tools to download for language id: \(languageId)")
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
            
            let toolIds: [ToolDownloadDataModelId] = downloadTools.map {
                ToolDownloadDataModelId(toolId: $0.toolId, languages: $0.languages)
            }
            
            Task {
                try await downloadToolsForLanguage(tools: downloadTools, languageId: languageId)
            }
            
            return toolDownloader
                .observeToolsChangesPublisher(toolIds: toolIds)
                .flatMap { (toolDownloads: [ToolDownloadDataModel]) -> AnyPublisher<Double, Error> in
                    
                    let toolsDownloadProgress: [Double] = toolDownloads.map { $0.progress }
                    let downloadError: String? = toolDownloads.first(where: { $0.downloadErrorDescription != nil })?.downloadErrorDescription
                    
                    let downloadProgress: Double = toolsDownloadProgress.getAverage()
                    
                    if let downloadError = downloadError {
                        return Fail(error: NSError.errorWithDescription(description: downloadError))
                            .eraseToAnyPublisher()
                    }
                    
                    return Just(downloadProgress)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        catch let error {
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func downloadToolLanguage(languageId: String) async throws {
        
        let downloadTools: [DownloadToolData] = try getToolsToDownloadForLanguage(languageId: languageId)
        
        try await downloadToolsForLanguage(tools: downloadTools, languageId: languageId)
    }
    
    private func downloadToolsForLanguage(tools: [DownloadToolData], languageId: String) async throws {
        
        if try downloadedLanguagesRepository.getDownloadedLanguage(languageId: languageId) == nil {
            
            _ = try await downloadedLanguagesRepository.storeDownloadedLanguage(
                downloadedLanguage: DownloadedLanguageDataModel(
                    languageId: languageId,
                    downloadComplete: false,
                    createdAt: Date()
                )
            )
        }
        
        let downloadedTools: [ToolDownloadDataModel] = try await toolDownloader.downloadTools(tools: tools, requestPriority: .low)
        
        _ = try await downloadedLanguagesRepository.storeDownloadedLanguage(
            languageId: languageId,
            downloadComplete: true
        )
        
        let errorDescription: String? = downloadedTools.first(where: { $0.downloadErrorDescription != nil })?.downloadErrorDescription
        
        if let errorDescription = errorDescription, !errorDescription.isEmpty {
            throw NSError.errorWithDescription(description: errorDescription)
        }
    }
    
    func syncDownloadedLanguages() async throws {
        
        _ = try await downloadedLanguagesRepository.markAllDownloadsAsCompleted()
        
        let downloadedLanguages: [DownloadedLanguageDataModel] = try await downloadedLanguagesRepository.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: true
        )
        
        await withThrowingTaskGroup(of: Void.self) { group in
            
            for language in downloadedLanguages {
                group.addTask {
                    _ = try await self.downloadToolLanguage(languageId: language.languageId)
                }
            }
        }
    }
}
