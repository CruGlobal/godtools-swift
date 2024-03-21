//
//  AnalyticsConstants.swift
//  godtools
//
//  Created by Robert Eldredge on 12/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct AnalyticsConstants {
    struct Keys {
        static let appName = "cru.appname"
        static let contentLanguage = "cru.contentlanguage"
        static let contentLanguageSecondary = "cru.contentlanguagesecondary"
        static let exitLink = "cru.mobileexitlink"
        static let grMasterPersonID = "cru.grmpid"
        static let loggedInStatus = "cru.loggedinstatus"
        static let previousScreenName = "cru.previousscreenname"
        static let screenName = "cru.screenname"
        static let screenNameFirebase = "screen_name"
        static let shareAction = "cru.shareiconengaged"
        static let shareableId = "cru.shareable_id"
        static let siteSection = "cru.siteSection"
        static let siteSubSection = "cru.siteSubSection"
        static let source = "cru.source"
        static let ssoguid = "cru.ssoguid"
        static let toggleAction = "cru.toggleswitch"
        static let gospelPresentedTimedAction = "cru.presentingthegospel"
        static let presentingHolySpiritTimedAction = "cru.presentingtheholyspirit"
        static let newProfessingBelieverAction = "cru.newprofessingbelievers"
        static let emailSignUpAction = "cru.emailsignup"
        static let parallelLanguageToggle = "cru.parallellanguagetoggle"
        static let tool = "cru.tool"
        static let toolAboutOpened = "cru.tool_about_button"
        static let toolOpenTapped = "cru.tool_open_tap"
        static let toolOpened = "cru.tool_open_button"
        static let tutorialDismissed = "cru.tutorial_home_dismiss"
        static let tutorialVideo = "cru.tutorial_video"
        static let tutorialVideoId = "video_id"
        static let onboardingStart = "cru.onboarding_start"
        static let toolOpenedShortcutCountKey = "cru.tool-opened-shortcut"
        static let shareScreenEngagedCountKey = "cru.sharescreenengaged"
        static let shareScreenOpenedCountKey = "cru.share_screen_opened"
        static let debug = "debug"
    }
    
    struct Values {
        static let godTools = "GodTools App"
        static let isLoggedIn = "true"
        static let notLoggedIn = "false"
        static let exitLink = "Exit Link Engaged"
        static let kgpUSCircleToggled = "KGP-US Circle Toggled"
        static let kgpCircleToggled = "KGP Circle Toggled"
        static let kgpGospelPresented = "KGP Gospel Presented"
        static let kgpUSGospelPresented = "KGP-US Gospel Presented"
        static let fourLawsGospelPresented = "FourLaws Gospel Presented"
        static let theFourGospelPresented = "TheFour Gospel Presented"
        static let satisfiedHolySpiritPresented = "Satisfied Holy Spirit Presented"
        static let honorRestoredPresented = "HonorRestored Gospel Presented"
        static let kgpNewProfessingBeliever = "KGP New Professing Believer"
        static let kgpUSNewProfessingBeliever = "KGP-US New Professing Believer"
        static let fourLawsNewProfessingBeliever = "FourLaws New Professing Believer"
        static let theFourNewProfessingBeliever = "TheFour New Professing Believer"
        static let kgpEmailSignUp = "KGP Email Sign Up"
        static let fourLawsEmailSignUp = "FourLaws Email Sign Up"
        static let debugIsTrue = "true"
        static let debugIsFalse = "false"      
    }
    
    struct ActionNames {
        static let aboutToolOpened = "About Tool Open Button"
        static let lessonOpenTapped = "open_lesson"
        static let parallelLanguageToggled = "Parallel Language Toggled"
        static let shareIconEngaged = "Share Icon Engaged"
        static let shareScreenEngaged = "Share Screen Engaged"
        static let shareScreenOpened = "Share Screen Opened"
        static let shareShareable = "share_shareable"
        static let toolOpenedShortcut = "Tool Opened Shortcut"
        static let toolOpened = "open_tool"
        static let tutorialHomeDismiss = "Tutorial Home Dismiss"
        static let tutorialVideo = "Tutorial Video"
        static let openDetails = "open_details"
        static let viewedLessonsAction = "iam_lessons"
        static let viewedMyToolsAction = "iam_mytools"
        static let viewedToolsAction = "iam_tools"
    }
    
    struct Sources {
        static let allTools = "all_tools"
        static let favoriteTools = "favorite_tools"
        static let featured = "featured"
        static let lessons = "lessons"
        static let spotlight = "spotlight"
        static let toolDetails = "tool_details"
        static let versions = "versions"
    }
}
