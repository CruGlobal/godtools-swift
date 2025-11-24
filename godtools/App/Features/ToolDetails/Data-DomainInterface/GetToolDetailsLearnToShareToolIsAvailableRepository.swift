//
//  GetToolDetailsLearnToShareToolIsAvailableRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsShared

class GetToolDetailsLearnToShareToolIsAvailableRepository: GetToolDetailsLearnToShareToolIsAvailableRepositoryInterface {
    
    private let translationsRepository: TranslationsRepository
    
    init(translationsRepository: TranslationsRepository) {
        
        self.translationsRepository = translationsRepository
    }
    
    func getIsAvailablePublisher(toolId: String, primaryLanguage: BCP47LanguageIdentifier, parallelLanguage: BCP47LanguageIdentifier?) -> AnyPublisher<Bool, Never> {
        
        return Publishers.CombineLatest(
            getTranslationHasTipsPublisher(toolId: toolId, language: primaryLanguage),
            getTranslationHasTipsPublisher(toolId: toolId, language: parallelLanguage)
        )
        .map { (primaryTranslationHasTips: Bool, parallelTranslationHasTips: Bool) in
            
            return primaryTranslationHasTips || parallelTranslationHasTips
        }
        .eraseToAnyPublisher()
    }
    
    private func getTranslationHasTipsPublisher(toolId: String, language: BCP47LanguageIdentifier?) -> AnyPublisher<Bool, Never> {
        
        guard let language = language, let translation = translationsRepository.cache.getLatestTranslation(resourceId: toolId, languageCode: language) else {
            return Just(false)
                .eraseToAnyPublisher()
        }
        
        let manifestParserType: TranslationManifestParserType = .manifestOnly
        let includeRelatedFiles: Bool = false
        
        return translationsRepository.getTranslationManifestFromCache(translation: translation, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
            .catch({ (cacheError: Error) -> AnyPublisher<TranslationManifestFileDataModel, Error> in
                
                return self.translationsRepository.getTranslationManifestFromRemote(
                    translation: translation,
                    manifestParserType: manifestParserType,
                    requestPriority: .high,
                    includeRelatedFiles: includeRelatedFiles,
                    shouldFallbackToLatestDownloadedTranslationIfRemoteFails: true
                )
                .eraseToAnyPublisher()
            })
            .flatMap({ (translationManifestDataModel: TranslationManifestFileDataModel) -> AnyPublisher<Bool, Never> in
                
                return Just(translationManifestDataModel.manifest.hasTips)
                    .eraseToAnyPublisher()
            })
            .catch({ (error: Error) -> AnyPublisher<Bool, Never> in
                
                return Just(false)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
