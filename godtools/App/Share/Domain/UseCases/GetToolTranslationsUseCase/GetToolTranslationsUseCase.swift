//
//  GetToolTranslationsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolTranslationsUseCase {
    
    typealias TranslationId = String
    
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let languagesRepository: LanguagesRepository
    private let mobileContentParser: MobileContentParser
    
    private var getToolTranslationsCancellable: AnyCancellable?
        
    init(resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, languagesRepository: LanguagesRepository, mobileContentParser: MobileContentParser) {

        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.languagesRepository = languagesRepository
        self.mobileContentParser = mobileContentParser
    }
    
    func getToolTranslations(determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, downloadStarted: (() -> Void)?) -> AnyPublisher<ToolTranslationsDomainModel, URLResponseError> {
        
        var didInitiateDownloadStarted: Bool = false
        
        return determineToolTranslationsToDownload.determineToolTranslationsToDownload()
            .catch({ (error: DetermineToolTranslationsToDownloadError) -> AnyPublisher<DetermineToolTranslationsToDownloadResult, URLResponseError> in
                
                if !didInitiateDownloadStarted {
                    didInitiateDownloadStarted = true
                    downloadStarted?()
                }
                
                return self.resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachmentsFromRemote()
                    .flatMap { results in
                        return determineToolTranslationsToDownload.determineToolTranslationsToDownload()
                            .mapError { error in
                                return URLResponseError.otherError(error: error)
                            }
                    }
                    .eraseToAnyPublisher()
            })
            .mapError { error in
                return URLResponseError.otherError(error: error)
            }
            .flatMap({ result -> AnyPublisher<[TranslationManifestFileDataModel], URLResponseError> in
                   
                let translations: [TranslationModel] = result.translations
                let parserType: TranslationManifestParserType = .renderer
                
                return self.translationsRepository.getTranslationManifests(translations: translations, manifestParserType: parserType)
                    .catch({ (error: Error) -> AnyPublisher<[TranslationManifestFileDataModel], URLResponseError> in
                        
                        if !didInitiateDownloadStarted {
                            didInitiateDownloadStarted = true
                            downloadStarted?()
                        }
                        
                        return self.translationsRepository.downloadAndCacheTranslationsFiles(translations: translations)
                            .flatMap { files in
                                return self.translationsRepository.getTranslationManifests(translations: translations, manifestParserType: parserType)
                                    .mapError { error in
                                        return URLResponseError.otherError(error: error)
                                    }
                            }
                            .eraseToAnyPublisher()
                    })
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .flatMap({ translationManifests -> AnyPublisher<ToolTranslationsDomainModel, URLResponseError> in
                    
                return self.mapTranslationManifestsToToolTranslationsDomainModel(translationManifests: translationManifests)
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func mapTranslationManifestsToToolTranslationsDomainModel(translationManifests: [TranslationManifestFileDataModel]) -> AnyPublisher<ToolTranslationsDomainModel, Error> {
        
        guard let resource = translationManifests.first?.translation.resource else {
            return Fail(error: (NSError.errorWithDescription(description: "Failed to get resource on translation model.")))
                .eraseToAnyPublisher()
        }
        
        var languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest] = Array()
        
        for translationManifest in translationManifests {
            
            guard let language = translationManifest.translation.language else {
                return Fail(error: (NSError.errorWithDescription(description: "Failed to get language on translation model.")))
                    .eraseToAnyPublisher()
            }
            
            languageTranslationManifests.append(MobileContentRendererLanguageTranslationManifest(manifest: translationManifest.manifest, language: language))
        }
        
        return Just(ToolTranslationsDomainModel(tool: resource, languageTranslationManifests: languageTranslationManifests)).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

