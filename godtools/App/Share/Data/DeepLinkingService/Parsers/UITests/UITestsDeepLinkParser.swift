//
//  UITestsDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 3/28/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class UITestsDeepLinkParser: DeepLinkUrlParserInterface {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String: Any]) -> ParsedDeepLinkType? {
        
        let appLanguage: AppLanguageDomainModel = (queryParameters["appLanguageCode"] as? String) ?? LanguageCodeDomainModel.english.value
        
        let screenPath: String? = pathComponents[safe: 1]
        
        if screenPath == "menu" {
            
            return .menu
        }
        else if screenPath == "onboarding" {
            
            return .onboarding(appLanguage: appLanguage)
        }
        else if screenPath == "settings" && pathComponents[safe: 2] == "language" {
            
            return .languageSettings
        }
        else if screenPath == "settings" && pathComponents[safe: 2] == "localization" {
            
            return .localizationSettings
        }
        else if screenPath == "settings" && pathComponents[safe: 2] == "app_languages" {
            
            return .appLanguagesList
        }
        else if screenPath == "tutorial" {
            
            return .tutorial
        }
        
        return nil
    }
}
