//
//  DownloadToolLanguageRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DownloadToolLanguageRepository: DownloadToolLanguageRepositoryInterface {
    
    private let downloadedLanguagesRepository: DownloadedLanguagesRepository
    private let resourcesRepository: ResourcesRepository
    private let toolDownloader: ToolDownloader
    
    init(downloadedLanguagesRepository: DownloadedLanguagesRepository, resourcesRepository: ResourcesRepository, toolDownloader: ToolDownloader) {
        
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.resourcesRepository = resourcesRepository
        self.toolDownloader = toolDownloader
    }
    
    func downloadToolTranslations(for languageId: String, languageCode: BCP47LanguageIdentifier) -> AnyPublisher<Double, Never> {
            
        downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageId, downloadComplete: false)
        
        let includeToolTypes: [ResourceType] = ResourceType.toolTypes + [.lesson]
        
        let tools: [ResourceModel] = resourcesRepository.getCachedResourcesByFilter(filter: ResourcesFilter(category: nil, languageCode: languageCode, resourceTypes: includeToolTypes))
       
        let downloadTools: [DownloadToolDataModel] = tools.map({
            DownloadToolDataModel(toolId: $0.id, languages: [languageCode])
        })
        
        guard !downloadTools.isEmpty else {
            
            return Just(1)
                .eraseToAnyPublisher()
        }
        
        return toolDownloader.downloadToolsPublisher(tools: downloadTools)
            .map {
                
                let progress = $0.progress
                
                if progress >= 1 {
                    self.downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageId, downloadComplete: true)
                }
                
                return $0.progress
            }
            .eraseToAnyPublisher()
    }
}
