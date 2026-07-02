//
//  GetToolDetailsLearnToShareToolIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolDetailsLearnToShareToolIsAvailableUseCase {
    
    private let translationsRepository: TranslationsRepository
    
    init(translationsRepository: TranslationsRepository) {
        
        self.translationsRepository = translationsRepository
    }
    
    func execute(toolId: String, primaryLanguage: BCP47LanguageIdentifier, parallelLanguage: BCP47LanguageIdentifier?) -> AnyPublisher<Bool, Never> {
        
        return AnyPublisher() {
            try await self.asyncExecute(
                toolId: toolId,
                primaryLanguage: primaryLanguage,
                parallelLanguage: parallelLanguage
            )
        }
        .catch { _ in
            return Just(false)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private func asyncExecute(toolId: String, primaryLanguage: BCP47LanguageIdentifier, parallelLanguage: BCP47LanguageIdentifier?) async throws -> Bool {
        
        let primaryHasTips: Bool = try await getTranslationHasTips(toolId: toolId, language: primaryLanguage)
        
        if primaryHasTips {
            return true
        }
        
        return try await getTranslationHasTips(toolId: toolId, language: parallelLanguage)
    }
    
    private func getTranslationHasTips(toolId: String, language: BCP47LanguageIdentifier?) async throws -> Bool {
        
        guard let language = language,
              let translation = translationsRepository.getLatestTranslation(resourceId: toolId, languageCode: language) else {
            
            return false
        }
        
        let manifestParserType: TranslationManifestParserType = .manifestOnly
        let includeRelatedFiles: Bool = false
        
        return try await translationsRepository.getTranslationManifestFromCacheElseRemote(
            translation: translation,
            manifestParserType: manifestParserType,
            requestPriority: .high,
            includeRelatedFiles: includeRelatedFiles,
            shouldFallbackToLatestDownloadedTranslationIfRemoteFails: true
        ).manifest.hasTips
    }
}
