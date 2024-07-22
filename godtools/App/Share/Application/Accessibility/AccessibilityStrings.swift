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
        case articles = "Articles"
        case askAQuestion = "Ask A Question"
        case confirmAppLanguage = "Confirm App Language"
        case copyrightInfo = "Copyright Info"
        case createAccount = "Create Account"
        case dashboardFavorites = "Dashboard Favorites"
        case dashboardLessons = "Dashboard Lessons"
        case dashboardTools = "Dashboard Tools"
        case downloadableLanguages = "Downloadable Languages"
        case languageSettings = "Language Settings"
        case leaveAReview = "Leave A Review"
        case login = "Login"
        case onboardingTutorial = "Onboarding Tutorial Screen"
        case onboardingTutorialPage1 = "Onboarding Tutorial Page 1"
        case onboardingTutorialPage2 = "Onboarding Tutorial Page 2"
        case onboardingTutorialPage3 = "Onboarding Tutorial Page 3"
        case onboardingTutorialPage4 = "Onboarding Tutorial Page 4"
        case menu = "Menu"
        case privacyPolicy = "Privacy Policy"
        case reportABug = "Report A Bug"
        case sendFeedback = "Send Feedback"
        case shareAStoryWithUs = "Share A Story With Us"
        case shareGodTools = "Share GodTools"
        case termsOfUse = "Terms Of Use"
        case toolDetails = "Tool Details"
        case toolsCategoryFilters = "Tools Category Filters"
        case toolsLanguageFilters = "Tools Language Filters"
        case tutorial = "Tutorial"
        case watchOnboardingTutorialVideo = "Watch Onboarding Tutorial Video Screen"
    }
    
    enum Button: String {
        
        var id: String {
            return rawValue
        }
        
        case activity = "Activity"
        case appLanguageListItem = "App Language List Item"
        case askAQuestion = "Ask A Question"
        case closeOnboardingTutorialVideo = "Close Onboarding Tutorial Video Button"
        case chooseAppLanguage = "Choose App Language"
        case copyrightInfo = "Copyright Info"
        case createAccount = "Create Account"
        case dashboardMenu = "Menu"
        case dashboardTabFavorites = "Dashboard Tab Favorites"
        case dashboardTabLessons = "Dashboard Tab Lessons"
        case dashboardTabTools = "Dashboard Tab Tools"
        case deleteAccount = "Delete Account"
        case editDownloadedLanguages = "Edit Downloaded Languages"
        case favoriteTool = "Favorite Tool"
        case languageSettings = "Language Settings"
        case leaveAReview = "Leave A Review"
        case login = "Login"
        case logout = "Logout"
        case nextOnboardingTutorial = "Next Onboarding Tutorial Button"
        case openTool = "Open Tool"
        case privacyPolicy = "Privacy Policy"
        case reportABug = "Report A Bug"
        case sendFeedback
        case shareAStoryWithUs = "Share A Story With Us"
        case shareGodTools = "Share GodTools"
        case skipOnboardingTutorial = "Skip Onboarding Tutorial Button"
        case spotlightTool = "Spotlight Tool"
        case termsOfUse = "Terms Of Use"
        case toggleToolFavorite = "Toggle Tool Favorite"
        case tool = "Tool"
        case toolDetails = "Tool Details"
        case toolDetailsNavBack = "Tool Details Nav Back"
        case toolsCategoryFilter = "Tools Category Filter"
        case toolsLanguageFilter = "Tools Language Filter"
        case tutorial = "Tutorial"
        case watchOnboardingTutorialVideo = "Watch Onboarding Tutorial Video Button"
        
    }
}
