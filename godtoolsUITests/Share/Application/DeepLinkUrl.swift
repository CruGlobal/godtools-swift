//
//  DeepLinkUrl.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct DeepLinkUrl {
    
    private static let host: String = "godtools://org.cru.godtools"
    
    static func getDashboardFavorites() -> String {
        return "\(host)/dashboard/favorites"
    }
    
    static func getDashboardLessons() -> String {
        return "\(host)/dashboard/lessons"
    }
    
    static func getDashboardTools() -> String {
        return "\(host)/dashboard/tools"
    }
    
    static func getMenu() -> String {
        return "\(host)/ui_tests/menu"
    }
    
    static func getOnboarding(appLanguageCode: String = LanguageCodeDomainModel.english.value) -> String {
        return "\(host)/ui_tests/onboarding?appLanguageCode=\(appLanguageCode)"
    }
    
    static func getSettingsAppLanguages() -> String {
        return "\(host)/ui_tests/settings/app_languages"
    }
    
    static func getSettingsLanguage() -> String {
        return "\(host)/ui_tests/settings/language"
    }
    
    static func getSettingsLocalization() -> String {
        return "\(host)/ui_tests/settings/localization"
    }
    
    static func getToolDetails(toolId: String) -> String {
        return "\(host)/ui_tests/tooldetails?tool_id=\(toolId)"
    }
    
    static func getTract(abbreviation: String, languageCode: String = LanguageCodeDomainModel.english.value) -> String {
        return "\(host)/tool/tract/\(abbreviation)/\(languageCode)"
    }
    
    static func getTutorial() -> String {
        return "\(host)/ui_tests/tutorial"
    }
}
