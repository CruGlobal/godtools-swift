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
        static let siteSection = "cru.siteSection"
        static let siteSubSection = "cru.siteSubSection"
        static let ssoguid = "cru.ssoguid"
        static let snowplowid = "cru.snowplowid"
        static let debug = "debug"
    }
    
    struct Values {
        static let godTools = "GodTools App"
        static let isLoggedIn = "true"
        static let notLoggedIn = "false"
        static let share = "Share Icon Engaged"
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
        static let parallelLanguageToggle = "Parallel Language Toggled"
        static let debugIsTrue = "true"
        static let debugIsFalse = "false"
        static let toolOpenedShortcut = "Tool Opened Shortcut"
        static let shareIconEngaged = "Share Icon Engaged"
        static let shareScreenEngaged = "Share Screen Engaged"
        static let shareScreenOpened = "Share Screen Opened"
        static let onboardingQuickStartArticles = "onboarding_link_articles"
        static let onboardingQuickStartLessons = "onboarding_link_lessons"
        static let onboardingQuickStartTools = "onboarding_link_tools"
    }
    
    struct ActionNames {
        static let shareIconEngagedCountKey = "cru.shareiconengaged"
        static let toggleAction = "cru.toggleswitch"
        static let gospelPresentedTimedAction = "cru.presentingthegospel"
        static let presentingHolySpiritTimedAction = "cru.presentingtheholyspirit"
        static let newProfessingBelieverAction = "cru.newprofessingbelievers"
        static let emailSignUpAction = "cru.emailsignup"
        static let parallelLanguageToggle = "cru.parallellanguagetoggle"
        static let toolOpenedShortcutCountKey = "cru.tool-opened-shortcut"
        static let shareScreenEngagedCountKey = "cru.sharescreenengaged"
        static let shareScreenOpenedCountKey = "cru.share_screen_opened"
    }
}
