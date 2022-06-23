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
    private let localizationServices: LocalizationServices
    
    required init(languagesRepository: LanguagesRepository, localizationServices: LocalizationServices) {
        
        self.languagesRepository = languagesRepository
        self.localizationServices = localizationServices
    }
    
    func getToolLanguages(resource: ResourceModel) -> [ToolLanguageModel] {
        
        let languages: [LanguageModel] = languagesRepository.getLanguages(ids: resource.languageIds)
        
        let toolLanguages: [ToolLanguageModel] = languages.map({
            ToolLanguageModel(
                id: $0.id,
                name: LanguageViewModel(language: $0, localizationServices: localizationServices).translatedLanguageName
            )
        })
        
        return toolLanguages
    }
}
