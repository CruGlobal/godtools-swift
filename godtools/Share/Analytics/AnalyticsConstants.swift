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
        static let previousScreenName = "cru_previousscreenname"
        static let screenName = "cru_screenname"
        static let siteSection = "cru_siteSection"
        static let siteSubSection = "cru_siteSubSection"
        static let ssoguid = "cru_ssoguid"
    }
    
    struct Values {
        static let godTools = "GodTools"
        static let isLoggedIn = "is logged in"
        static let notLoggedIn = "not logged in"
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
    }
    
    struct ActionNames {
        static let shareAction = "cru.shareiconengaged"
        static let toggleAction = "cru.toggleswitch"
        static let gospelPresentedTimedAction = "cru.presentingthegospel"
        static let presentingHolySpiritTimedAction = "cru.presentingtheholyspirit"
        static let newProfessingBelieverAction = "cru.newprofessingbelievers"
        static let emailSignUpAction = "cru.emailsignup"
        static let parallelLanguageToggle = "cru.parallellanguagetoggle"
    }
}
