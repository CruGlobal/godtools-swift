//
//  LanguagesManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

class LanguagesManager {
           
    static let shared: LanguagesManager = LanguagesManager()
    
    private var languageSettingsService: LanguageSettingsService?
    
    private init() {
        
    }
    
    func setup(languageSettingsService: LanguageSettingsService) {
        
        self.languageSettingsService = languageSettingsService
    }
    
    var primaryLangauge: LanguageModel? {
        return languageSettingsService?.primaryLanguage.value
    }
}
