//
//  UITestsDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 3/28/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class UITestsDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        let appLanguage: AppLanguageDomainModel = (queryParameters["appLanguageCode"] as? String) ?? LanguageCodeDomainModel.english.value
        
        let screenPath: String? = pathComponents[safe: 1]
        
        if screenPath == "onboarding" {
            
            return .onboarding(appLanguage: appLanguage)
        }
        else if screenPath == "settings" && pathComponents[safe: 2] == "language" {
            
            return .languageSettings
        }
        else if screenPath == "settings" && pathComponents[safe: 2] == "app_languages" {
            
            return .appLanguagesList
        }
        
        return nil
    }
}
