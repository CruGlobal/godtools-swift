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
    
    init(resourcesRepository: ResourcesRepository, languagesRepository: LanguagesRepository, toolDownloader: ToolDownloader, downloadedLanguagesRepository: DownloadedLanguagesRepository) {
     
        self.resourcesRepository = resourcesRepository
        self.languagesRepository = languagesRepository
        self.toolDownloader = toolDownloader
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
    }
    
    func downloadToolLanguagePublisher(languageId: String) -> AnyPublisher<ToolDownloaderDataModel, Never> {
        
        guard let languageModel = languagesRepository.getLanguage(id: languageId) else {
            
            let error: Error = NSError.errorWithDomain(domain: "ToolLanguageDownloader", code: -1, description: "Internal Error in ToolLanguageDownloader.  Failed to fetch language with language id: \(languageId)")
            
            let dataModel = ToolDownloaderDataModel(
                attachments: [],
                progress: 0,
                translations: [],
                errors: [error]
            )
            
            return Just(dataModel)
                .eraseToAnyPublisher()
        }
                
        let includeToolTypes: [ResourceType] = ResourceType.toolTypes + [.lesson]
        
        let tools: [ResourceModel] = resourcesRepository.getCachedResourcesByFilter(
            filter: ResourcesFilter(category: nil, languageModelCode: languageModel.code, resourceTypes: includeToolTypes)
        )
        
        let downloadTools: [DownloadToolDataModel] = tools.map({
            DownloadToolDataModel(toolId: $0.id, languages: [languageModel.code])
        })
                
        return toolDownloader.downloadToolsPublisher(tools: downloadTools)
            .eraseToAnyPublisher()
    }
    
    func syncDownloadedLanguagesPublisher() -> AnyPublisher<Void, Never> {
        
        downloadedLanguagesRepository.markAllDownloadsCompletedPublisher()
        
        return downloadedLanguagesRepository.getDownloadedLanguagesPublisher(completedDownloadsOnly: false)
            .flatMap({ (downloadedLanguages: [DownloadedLanguageDataModel]) -> AnyPublisher<Void, Never> in
                                
                let downloadToolLanguageRequests: [AnyPublisher<ToolDownloaderDataModel, Never>] = downloadedLanguages.map({
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
