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
            
            let emptyDownload = ToolDownloaderDataModel(attachments: [], progress: 1, translations: [])
            
            return Just(emptyDownload)
                .eraseToAnyPublisher()
        }
                
        let includeToolTypes: [ResourceType] = ResourceType.toolTypes + [.lesson]
        
        let tools: [ResourceModel] = resourcesRepository.getCachedResourcesByFilter(filter: ResourcesFilter(category: nil, languageCode: languageModel.code, resourceTypes: includeToolTypes))
        
        let downloadTools: [DownloadToolDataModel] = tools.map({
            DownloadToolDataModel(toolId: $0.id, languages: [languageModel.code])
        })
                
        return toolDownloader.downloadToolsPublisher(tools: downloadTools)
            .eraseToAnyPublisher()
    }
    
    func syncDownloadedLanguagesPublisher() -> AnyPublisher<Void, Never> {
        
        return downloadedLanguagesRepository.getDownloadedLanguagesPublisher(completedDownloadsOnly: false)
            .flatMap({ (downloadedLanguages: [DownloadedLanguageDataModel]) -> AnyPublisher<Void, Never> in
                                
                let downloadToolLanguageRequests = downloadedLanguages.map({
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
