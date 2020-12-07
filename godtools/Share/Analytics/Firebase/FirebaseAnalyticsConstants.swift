//
//  FirebaseAnalyticsConstants.swift
//  godtools
//
//  Created by Robert Eldredge on 12/7/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct FirebaseAnalyticsConstants {
    struct Keys {
        static let shareAction = "cru_shareiconengaged"
        static let toggleAction = "cru_toggleswitch"
        static let gospelPresentedTimedAction = "cru_presentingthegospel"
        static let presentingHolySpiritTimedAction = "cru_presentingtheholyspirit"
        static let newProfessingBelieverAction = "cru_newprofessingbelievers"
        static let emailSignUpAction = "cru_emailsignup"
        static let parallelLanguageToggle = "cru_parallellanguagetoggle"
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
}
