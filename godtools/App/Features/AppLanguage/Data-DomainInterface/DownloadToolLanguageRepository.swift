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
    private let translationsRepository: TranslationsRepository
    
    init(downloadedLanguagesRepository: DownloadedLanguagesRepository, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.downloadedLanguagesRepository = downloadedLanguagesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    func downloadToolTranslations(for languageCode: BCP47LanguageIdentifier) -> AnyPublisher<Double, Error> {
            
            downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageCode, downloadProgress: 0)
        
            let includeToolTypes: [ResourceType] = [.article, .tract, .lesson, .chooseYourOwnAdventure]
            
            let tools: [ResourceModel] = resourcesRepository.getCachedResourcesByFilter(filter: ResourcesFilter(category: nil, languageCode: languageCode, resourceTypes: includeToolTypes))
           
            let translations: [TranslationModel] = tools.compactMap {
                translationsRepository.getLatestTranslation(resourceId: $0.id, languageCode: languageCode)
            }
            
            guard !translations.isEmpty else {
                return Just(1).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            return translationsRepository.getTranslationManifestsFromRemoteWithProgress(
                translations: translations,
                manifestParserType: .renderer,
                includeRelatedFiles: true,
                shouldFallbackToLatestDownloadedTranslationIfRemoteFails: true
            )
            .map {
                return $0.progress
            }
            .eraseToAnyPublisher()
        }
}
