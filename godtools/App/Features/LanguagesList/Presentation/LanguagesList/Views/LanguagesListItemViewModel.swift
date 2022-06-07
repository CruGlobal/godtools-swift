//
//  LanguagesListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class LanguagesListItemViewModel: ObservableObject {
    
    private let language: ToolLanguageModel
    private let selectedLanguageId: String?
    
    @Published var name: String = ""
    @Published var isSelected: Bool = false
    
    required init(language: ToolLanguageModel, selectedLanguageId: String?) {
        
        self.language = language
        self.selectedLanguageId = selectedLanguageId
        self.name = language.name
        self.isSelected = language.id == selectedLanguageId
    }
}
