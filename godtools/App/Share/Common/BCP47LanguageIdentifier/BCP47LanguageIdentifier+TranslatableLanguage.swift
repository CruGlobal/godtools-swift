//
//  BCP47LanguageIdentifier+TranslatableLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 1/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

extension BCP47LanguageIdentifier: TranslatableLanguage {
    
    var localeId: BCP47LanguageIdentifier {
        return self
    }
    
    var languageCode: String {
            
        let locale = Locale(identifier: localeId)
        let languageCode: String? = locale.language.languageCode?.identifier

        return languageCode ?? localeId
    }
    
    var regionCode: String? {
            
        let languageComponents: [String] = localeId.components(separatedBy: "-")
        
        guard languageComponents.count > 1 else {
            return nil
        }
        
        let locale = Locale(identifier: localeId)
        let regionCode: String? = locale.language.region?.identifier
        
        guard let regionCode = regionCode else {
            return nil
        }
        
        let regionCodeExistsInLanguageId: Bool = languageComponents.first(where: {
            $0.lowercased() == regionCode.lowercased()
        }) != nil
        
        guard regionCodeExistsInLanguageId else {
            return nil
        }
        
        return regionCode
    }
    
    var scriptCode: String? {
        
        let languageComponents: [String] = localeId.components(separatedBy: "-")
        
        guard languageComponents.count > 1 else {
            return nil
        }
        
        let locale = Locale(identifier: localeId)
        let scriptCode: String? = locale.language.script?.identifier
        
        guard let scriptCode = scriptCode else {
            return nil
        }
        
        let scriptCodeExistsInLanguageId: Bool = languageComponents.first(where: {
            $0.lowercased() == scriptCode.lowercased()
        }) != nil
        
        guard scriptCodeExistsInLanguageId else {
            return nil
        }
        
        return scriptCode
    }
    
    var fallbackName: String {
        return ""
    }
    
    var forceLanguageName: Bool {
        return false
    }
}
