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
    private let toolLanguageDownloader: ToolLanguageDownloader
    
    init(downloadedLanguagesRepository: DownloadedLanguagesRepository, resourcesRepository: ResourcesRepository, toolLanguageDownloader: ToolLanguageDownloader) {
        
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.resourcesRepository = resourcesRepository
        self.toolLanguageDownloader = toolLanguageDownloader
    }
    
    func downloadToolTranslations(for languageId: String, languageCode: BCP47LanguageIdentifier) -> AnyPublisher<Double, Never> {
            
        downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageId, downloadComplete: false)
        
        return toolLanguageDownloader
            .downloadToolLanguagePublisher(languageId: languageId)
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
