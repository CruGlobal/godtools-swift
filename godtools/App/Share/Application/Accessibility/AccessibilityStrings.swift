//
//  AccessibilityStrings.swift
//  godtools
//
//  Created by Levi Eggert on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccessibilityStrings {
    
    enum Screen: String {
        
        var id: String {
            return rawValue
        }
        
        case appLanguages = "App Languages"
        case downloadableLanguages = "Downloadable Languages"
        case languageSettings = "Language Settings"
        case confirmAppLanguage = "Confirm App Language"
        case onboardingTutorial = "Onboarding Tutorial Screen"
        case onboardingTutorialPage1 = "Onboarding Tutorial Page 1"
        case onboardingTutorialPage2 = "Onboarding Tutorial Page 2"
        case onboardingTutorialPage3 = "Onboarding Tutorial Page 3"
        case onboardingTutorialPage4 = "Onboarding Tutorial Page 4"
        case watchOnboardingTutorialVideo = "Watch Onboarding Tutorial Video Screen"
        case dashboardLessons = "Dashboard Lessons"
        case dashboardFavorites = "Dashboard Favorites"
        case dashboardTools = "Dashboard Tools"
        case articles = "Articles"
    }
    
    enum Button: String {
        
        var id: String {
            return rawValue
        }
        
        case chooseAppLanguage = "Choose App Language"
        case appLanguageListItem = "App Language List Item"
        case watchOnboardingTutorialVideo = "Watch Onboarding Tutorial Video Button"
        case closeOnboardingTutorialVideo = "Close Onboarding Tutorial Video Button"
        case nextOnboardingTutorial = "Next Onboarding Tutorial Button"
        case skipOnboardingTutorial = "Skip Onboarding Tutorial Button"
        case editDownloadedLanguages = "Edit Downloaded Languages"
    }
}
