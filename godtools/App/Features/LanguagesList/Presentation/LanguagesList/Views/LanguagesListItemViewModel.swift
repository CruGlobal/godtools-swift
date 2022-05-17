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
    
    @Published var name: String = ""
    
    required init(language: ToolLanguageModel) {
        
        self.language = language
        self.name = language.name
    }
}
