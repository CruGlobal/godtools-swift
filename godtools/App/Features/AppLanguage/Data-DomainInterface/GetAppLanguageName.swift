//
//  GetAppLanguageName.swift
//  godtools
//
//  Created by Levi Eggert on 12/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class GetAppLanguageName {
    
    private let localeLanguageName: LocaleLanguageName
    private let localeLanguageScriptName: LocaleLanguageScriptName
    
    init(localeLanguageName: LocaleLanguageName, localeLanguageScriptName: LocaleLanguageScriptName) {
        
        self.localeLanguageName = localeLanguageName
        self.localeLanguageScriptName = localeLanguageScriptName
    }
    
    func getName(languageCode: String, scriptCode: String?, translatedInLanguage: AppLanguageDomainModel) -> String {
                
        let languageName: String? = localeLanguageName.getLanguageName(forLanguageCode: languageCode, translatedInLanguageId: translatedInLanguage)
        let languageScriptName: String?
        
        if let scriptCode = scriptCode {
            languageScriptName = localeLanguageScriptName.getScriptName(forScriptCode: scriptCode, translatedInLanguageId: translatedInLanguage)
        }
        else {
            languageScriptName = nil
        }
        
        guard let languageName = languageName else {
            return ""
        }
        
        if let languageScriptName = languageScriptName, !languageScriptName.isEmpty {
            
            return languageName + " " + "(" + languageScriptName + ")"
        }
        else {
            
            return languageName
        }
    }
}
