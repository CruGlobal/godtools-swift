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
        case learnToShareTool
        case languageSettings = "Language Settings"
        case leaveAReview = "Leave A Review"
        case login = "Login"
        case onboardingTutorial = "Onboarding Tutorial Screen"
        case onboardingTutorialPage = "Onboarding Tutorial Page"
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
        case toolScreenShareTutorial = "Tool Screen Share Tutorial"
        case toolSettings = "Tool Settings"
        case tract = "Tract"
        case tutorial = "Tutorial"
        case watchOnboardingTutorialVideo = "Watch Onboarding Tutorial Video Screen"
        
        static func getPageAccessibility(screen: Screen, page: Int) -> String {
            return screen.id + "-" + String(page)
        }
    }
    
    enum Button: String {
        
        var id: String {
            return rawValue
        }
        
        case activity = "Activity"
        case appLanguageListItem = "App Language List Item"
        case askAQuestion = "Ask A Question"
        case close = "Close"
        case chooseAppLanguage = "Choose App Language"
        case continueForward = "Continue"
        case copyrightInfo = "Copyright Info"
        case createAccount = "Create Account"
        case dashboardMenu = "Menu"
        case dashboardTabFavorites = "Dashboard Tab Favorites"
        case dashboardTabLessons = "Dashboard Tab Lessons"
        case dashboardTabTools = "Dashboard Tab Tools"
        case deleteAccount = "Delete Account"
        case editDownloadedLanguages = "Edit Downloaded Languages"
        case favoriteTool = "Favorite Tool"
        case generateQRCode = "Generate QR Code"
        case getStarted = "Get Started"
        case languageSettings = "Language Settings"
        case localizationSettings = "Localization Settings"
        case learnToShare = "Learn To Share"
        case leaveAReview = "Leave A Review"
        case lessonsLanguageFilter = "Lessons Language Filter"
        case login = "Login"
        case logout = "Logout"
        case openTool = "Open Tool"
        case privacyPolicy = "Privacy Policy"
        case reportABug = "Report A Bug"
        case sendFeedback
        case shareAStoryWithUs = "Share A Story With Us"
        case shareGodTools = "Share GodTools"
        case shareLink = "Share Link"
        case shareScreen = "Share Screen"
        case skip = "Skip"
        case spotlightTool = "Spotlight Tool"
        case startTraining = "Start Training"
        case termsOfUse = "Terms Of Use"
        case toggleToolFavorite = "Toggle Tool Favorite"
        case tool = "Tool"
        case toolDetails = "Tool Details"
        case toolDetailsNavBack = "Tool Details Nav Back"
        case toolsCategoryFilter = "Tools Category Filter"
        case toolsLanguageFilter = "Tools Language Filter"
        case toolSettings = "Tool Settings"
        case trainingTips = "Training Tips"
        case tutorial = "Tutorial"
        case watchOnboardingTutorialVideo = "Watch Onboarding Tutorial Video Button"
        
        static func getToolButtonAccessibility(toolButton: Button, toolName: Button.ToolName) -> String {
            return Self.getToolButtonAccessibility(toolButton: toolButton, toolName: toolName.rawValue)
        }
        
        static func getToolButtonAccessibility(toolButton: Button, toolName: String) -> String {
            return toolButton.id + " - " + toolName.lowercased()
        }
        
        enum ToolName: String {
            case fourSpiritualLaws = "four spiritual laws"
            case knowingGodPersonally = "knowing god personally"
            case teachMeToShare = "teach me to share"
        }
    }
}
