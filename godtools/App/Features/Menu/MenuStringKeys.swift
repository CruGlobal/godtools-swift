//
//  MenuStrings.swift
//  godtools
//
//  Created by Rachael Skeath on 3/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class MenuStringKeys {
    
    enum SectionTitles: String {
        case getStarted = "menu_getStarted"
        case account = "menu_account"
        case support = "menu_support"
        case share = "menu_share"
        case about = "menu_about"
        case version = "menu_version"
    }
    
    enum ItemTitles: String {
        case tutorial = "menu.tutorial"
        case languageSettings = "language_settings"
        case login = "login"
        case activity = "account.activity.title"
        case createAccount = "create_account"
        case logout = "logout"
        case deleteAccount = "menu.deleteAccount"
        case sendFeedback = "menu.sendFeedback"
        case reportABug = "menu.reportABug"
        case askAQuestion = "menu.askAQuestion"
        case leaveAReview = "menu.leaveAReview"
        case shareAStoryWithUs = "share_a_story_with_us"
        case shareGodTools = "share_god_tools"
        case termsOfUse = "terms_of_use"
        case privacyPolicy = "privacy_policy"
        case copyrightInfo = "copyright_info"
    }
    
    enum SocialSignIn: String {
        case signInTitle = "signIn.title"
        case subtitle = "signIn.subtitle"
        case googleSignIn = "signIn.google"
        case facebookSignIn = "signIn.facebook"
        case appleSignIn = "signIn.apple"
    }
    
    enum Account: String {
        case navTitle = "account.navTitle"
        case activityButtonTitle = "account.activity.title"
        case activitySectionTitle = "account.activity.sectionTitle"
        case badgesSectionTitle = "account.badges.sectionTitle"
        
        enum Activity: String {
            case languagesUsed = "account.activity.languagesUsed"
            case lessonCompletions = "account.activity.lessonCompletions"
            case linksShared = "account.activity.linksShared"
            case screenShares = "account.activity.screenShares"
            case sessions = "account.activity.sessions"
            case toolOpens = "account.activity.toolOpens"
        }
        
        case globalActivityButtonTitle = "account.globalActivity.title"
        case globalAnalyticsTitle = "accountActivity.globalAnalytics.header.title"
    }
    
    enum DeleteAccount: String {
        
        case title = "deleteAccount.title"
        case subtitle = "deleteAccount.subtitle"
        case confirmButtonTitle = "deleteAccount.confirmButton.title"
        case cancelButtonTitle = "deleteAccount.cancelButton.title"
    }
}
