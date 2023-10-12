//
//  GetToolLanguagesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetToolLanguagesUseCase {
    
    private let languagesRepository: LanguagesRepository
    private let getLanguageUseCase: GetLanguageUseCase
    
    required init(languagesRepository: LanguagesRepository, getLanguageUseCase: GetLanguageUseCase) {
        
        self.languagesRepository = languagesRepository
        self.getLanguageUseCase = getLanguageUseCase
    }
    
    func getToolLanguages(resource: ResourceModel) -> [LanguageDomainModel] {
        
        return languagesRepository.getLanguages(ids: resource.languageIds)
            .map({ getLanguageUseCase.getLanguage(language: $0) })
    }
}
