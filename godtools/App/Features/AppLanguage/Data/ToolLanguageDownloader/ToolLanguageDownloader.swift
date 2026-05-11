//
//  ToolLanguageDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class ToolLanguageDownloader {
    
    private let resourcesRepository: ResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let toolDownloader: ToolDownloader
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, toolDownloader: ToolDownloader, downloadedLanguagesRepository: DownloadedLanguagesRepository) {
     
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.toolDownloader = toolDownloader
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
    }
    
    func downloadToolLanguage(languageId: String) throws -> AsyncThrowingStream<ToolDownloaderDataModel, Error> {
        
        guard let languageModel = languagesRepository.getLanguage(id: languageId) else {
            
            throw NSError.errorWithDomain(
                domain: "ToolLanguageDownloader",
                code: -1,
                description: "Internal Error in ToolLanguageDownloader.  Failed to fetch language with language id: \(languageId)"
            )
        }
                
        let includeToolTypes: [ResourceType] = ResourceType.toolTypes + [.lesson]
        
        let tools: [ResourceDataModel] = resourcesRepository.getCachedResourcesByFilter(
            filter: ResourcesFilter(category: nil, languageModelCode: languageModel.code, resourceTypes: includeToolTypes)
        )
        
        let downloadTools: [DownloadToolDataModel] = tools.map({
            DownloadToolDataModel(toolId: $0.id, languages: [languageModel.code])
        })
                
        return toolDownloader.downloadToolsStream(
            tools: downloadTools,
            requestPriority: .low
        )
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
