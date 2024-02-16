//
//  GetToolDetailsLearnToShareToolIsAvailableRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

class GetToolDetailsLearnToShareToolIsAvailableRepository: GetToolDetailsLearnToShareToolIsAvailableRepositoryInterface {
    
    private let translationsRepository: TranslationsRepository
    
    init(translationsRepository: TranslationsRepository) {
        
        self.translationsRepository = translationsRepository
    }
    
    func getIsAvailablePublisher(toolId: String, language: BCP47LanguageIdentifier) -> AnyPublisher<Bool, Never> {
        
        guard let translation = translationsRepository.getLatestTranslation(resourceId: toolId, languageCode: language) else {
            return Just(false)
                .eraseToAnyPublisher()
        }
        
        let manifestParserType: TranslationManifestParserType = .manifestOnly
        let includeRelatedFiles: Bool = false
        
        return translationsRepository.getTranslationManifestFromCache(translation: translation, manifestParserType: manifestParserType, includeRelatedFiles: includeRelatedFiles)
            .catch ({ (cacheError: Error) -> AnyPublisher<TranslationManifestFileDataModel, Error> in
                
                return self.translationsRepository.getTranslationManifestFromRemote(
                    translation: translation,
                    manifestParserType: manifestParserType,
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
