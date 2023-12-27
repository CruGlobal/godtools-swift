//
//  GetToolSettingsToolHasTipsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsToolHasTipsRepository: GetToolSettingsToolHasTipsRepositoryInterface {
    
    private let translationsRepository: TranslationsRepository
    
    init(translationsRepository: TranslationsRepository) {
        
        self.translationsRepository = translationsRepository
    }
    
    func getHasTipsPublisher(tool: ResourceModel, toolLanguage: ToolSettingsToolLanguageDomainModel?) -> AnyPublisher<Bool, Never> {
        
        guard let languageId = toolLanguage?.dataModelId else {
            return Just(false)
                .eraseToAnyPublisher()
        }
        
        guard let translation = translationsRepository.getLatestTranslation(resourceId: tool.id, languageId: languageId) else {
            return Just(false)
                .eraseToAnyPublisher()
        }
        
        return translationsRepository.getTranslationManifestFromCache(translation: translation, manifestParserType: .manifestOnly, includeRelatedFiles: false)
            .map {
                return $0.manifest.hasTips
            }
            .catch { _ in
                return Just(false)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
