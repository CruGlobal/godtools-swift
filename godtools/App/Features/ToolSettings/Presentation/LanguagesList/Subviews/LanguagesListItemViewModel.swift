//
//  LanguagesListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LanguagesListItemViewModel: BaseLanguagesListItemViewModel {
    
    private let language: LanguageDomainModel
    private let selectedLanguageId: String?
    
    init(language: LanguageDomainModel, selectedLanguageId: String?) {
        
        self.language = language
        self.selectedLanguageId = selectedLanguageId
        
        super.init()
        
        self.name = language.translatedName
        self.isSelected = language.dataModelId == selectedLanguageId
    }
}
