//
//  GetAllToolLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllToolLanguagesUseCase {
    
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getLanguageUseCase: GetLanguageUseCase
    private let languagesRepository: LanguagesRepository
    private let resourcesRepository: ResourcesRepository
    
    init(getAllToolsUseCase: GetAllToolsUseCase, getLanguageUseCase: GetLanguageUseCase, languagesRepository: LanguagesRepository, resourcesRepository: ResourcesRepository) {
        
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getLanguageUseCase = getLanguageUseCase
        self.languagesRepository = languagesRepository
        self.resourcesRepository = resourcesRepository
    }
    
    func getAllToolLanguagesPublisher(filteredByCategory: ToolCategoryDomainModel?) -> AnyPublisher<[LanguageDomainModel], Never> {
        
        let languageIds = self.resourcesRepository
            .getAllTools(sorted: false, category: filteredByCategory?.id)
            .getUniqueLanguageIds()
        
        let languages = createLanguageDomainModels(from: Array(languageIds), withTranslation: nil, filteredByCategory: filteredByCategory)
        
        return Just(languages)
            .eraseToAnyPublisher()
    }
    
    private func createLanguageDomainModels(from languageIds: [String], withTranslation language: LanguageDomainModel?, filteredByCategory: ToolCategoryDomainModel?) -> [LanguageDomainModel] {
        
        return languagesRepository.getLanguages(ids: languageIds)
            .map { getLanguageUseCase.getLanguage(language: $0)}
    }
}

// MARK: - ResourceModel Array Extension

private extension Array where Element == ResourceModel {
    
    func getUniqueLanguageIds() -> Set<String> {
        
        let languageIds = flatMap { $0.languageIds }
        
        return Set(languageIds)
    }
}
