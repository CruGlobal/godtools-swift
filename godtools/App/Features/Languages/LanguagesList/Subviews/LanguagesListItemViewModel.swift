//
//  LanguagesListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LanguagesListItemViewModel: BaseLanguagesListItemViewModel {
    
    private let language: ToolLanguageModel
    private let selectedLanguageId: String?
    
    init(language: ToolLanguageModel, selectedLanguageId: String?) {
        
        self.language = language
        self.selectedLanguageId = selectedLanguageId
        
        super.init()
        
        self.name = language.name
        self.isSelected = language.id == selectedLanguageId
    }
}
