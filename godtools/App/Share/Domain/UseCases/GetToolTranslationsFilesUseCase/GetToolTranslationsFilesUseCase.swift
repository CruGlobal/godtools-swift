//
//  GetToolTranslationsFilesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

class GetToolTranslationsFilesUseCase {
    
    typealias TranslationId = String
    
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    private let languagesRepository: LanguagesRepository
    
    private var getToolTranslationsCancellable: AnyCancellable?
    private var didInitiateDownloadStarted: Bool = false
        
    init(resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, languagesRepository: LanguagesRepository) {

        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
        self.languagesRepository = languagesRepository
    }
    
    func getToolTranslationsFiles(filter: GetToolTranslationsFilesFilter, determineToolTranslationsToDownload: DetermineToolTranslationsToDownloadType, downloadStarted: (() -> Void)?) -> AnyPublisher<ToolTranslationsDomainModel, URLResponseError> {
                
        let manifestParserType: TranslationManifestParserType
        
        switch filter {
        case .downloadManifestAndRelatedFiles:
            manifestParserType = .related
        case .downloadManifestAndRelatedFilesForRenderer:
            manifestParserType = .renderer
        case .downloadManifestForTipsCount:
            manifestParserType = .tips(parseRelated: false)
        }
        
        return determineToolTranslationsToDownload.determineToolTranslationsToDownload().publisher
            .catch({ (error: DetermineToolTranslationsToDownloadError) -> AnyPublisher<DetermineToolTranslationsToDownloadResult, URLResponseError> in
                
                self.initiateDownloadStarted(downloadStarted: downloadStarted)
                
                return self.resourcesRepository.syncLanguagesAndResourcesPlusLatestTranslationsAndLatestAttachments()
                    .flatMap { results in
                        return determineToolTranslationsToDownload.determineToolTranslationsToDownload().publisher
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
                
                return self.translationsRepository.getTranslationManifestsFromCache(translations: translations, manifestParserType: manifestParserType)
                    .catch({ (error: Error) -> AnyPublisher<[TranslationManifestFileDataModel], URLResponseError> in
                        
                        self.initiateDownloadStarted(downloadStarted: downloadStarted)
                            
                        return self.translationsRepository.getTranslationManifestsFromRemote(translations: translations, manifestParserType: manifestParserType)
                            .eraseToAnyPublisher()
                    })
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main) // NOTE: Need to switch to main queue and parse manifests again because Manifests can't be passed across threads at this time. ~Levi
            .flatMap({ translationManifests -> AnyPublisher<[TranslationManifestFileDataModel], URLResponseError> in
                    
                let translations: [TranslationModel] = translationManifests.map({ $0.translation })
                
                return self.translationsRepository.getTranslationManifestsFromCache(translations: translations, manifestParserType: manifestParserType)
                    .mapError { error in
                        return .otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .flatMap({ translationManifests -> AnyPublisher<ToolTranslationsDomainModel, URLResponseError> in
                
                guard let resource = translationManifests.first?.translation.resource else {
                    
                    let error = NSError.errorWithDescription(description: "Failed to get resource on translation model.")
                    let responseError = URLResponseError.otherError(error: error)
                    
                    return Fail(error: responseError)
                        .eraseToAnyPublisher()
                }
                
                let languageManifets: [MobileContentRendererLanguageTranslationManifest] = translationManifests.compactMap({
                    
                    guard let language = $0.translation.language else {
                        return nil
                    }
                    
                    return MobileContentRendererLanguageTranslationManifest(manifest: $0.manifest, language: language)
                })
                
                let domainModel = ToolTranslationsDomainModel(tool: resource, languageTranslationManifests: languageManifets)
                
                return Just(domainModel).setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func initiateDownloadStarted(downloadStarted: (() -> Void)?) {
        
        guard !didInitiateDownloadStarted else {
            return
        }
        
        didInitiateDownloadStarted = true
        
        downloadStarted?()
    }
}


