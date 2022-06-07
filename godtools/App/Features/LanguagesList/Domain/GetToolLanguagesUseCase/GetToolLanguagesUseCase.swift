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
    
    required init(languagesRepository: LanguagesRepository) {
        
        self.languagesRepository = languagesRepository
    }
    
    func getToolLanguages(resource: ResourceModel) -> [ToolLanguageModel] {
        
        let languages: [LanguageModel] = languagesRepository.getLanguages(ids: resource.languageIds)
        
        let toolLanguages: [ToolLanguageModel] = languages.map({
            ToolLanguageModel(
                id: $0.id,
                name: $0.name
            )
        })
        
        return toolLanguages
    }
}
