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
    
    func downloadToolTranslations(for languageId: String) -> AnyPublisher<Double, Error> {
            
        downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageId, downloadComplete: false)
        
        return toolLanguageDownloader
            .downloadToolLanguagePublisher(languageId: languageId)
            .catch { (downloadError: Error) -> AnyPublisher<ToolDownloaderDataModel, Error> in

                return self.downloadedLanguagesRepository.deleteDownloadedLanguagePublisher(languageId: languageId)
                    .catch { (deleteError: Error) -> AnyPublisher<Void, Error> in

                        assertionFailure("Failed to delete object in RealmDatabase. \(deleteError.localizedDescription)")

                        return Fail(error: downloadError)
                            .eraseToAnyPublisher()
                    }
                    .flatMap({ (void: Void) -> AnyPublisher<ToolDownloaderDataModel, Error> in
                        return Fail(error: downloadError)
                            .eraseToAnyPublisher()
                    })
                    .eraseToAnyPublisher()
            }
            .map { (dataModel: ToolDownloaderDataModel) in
                
                let progress = dataModel.progress
                
                if progress >= 1 {
                    self.downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageId, downloadComplete: true)
                }
                
                return dataModel.progress
            }
            .eraseToAnyPublisher()
    }
}
