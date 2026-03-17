//
//  OnboardingTutorialStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct OnboardingTutorialStringsDomainModel: Sendable {
    
    let chooseAppLanguageButtonTitle: String
    let beginTutorialButtonTitle: String
    let nextTutorialPageButtonTitle: String
    let endTutorialButtonTitle: String
    let readyForEveryConversationTitle: String
    let readyForEveryConversationVideoLinkTitle: String
    let prepareForMomentsThatMatterTitle: String
    let prepareForMomentsThatMatterMessage: String
    let talkWithGodAboutAnyoneTitle: String
    let talkWithGodAboutAnyoneMessage: String
    let helpSomeoneDiscoverJesusTitle: String
    let helpSomeoneDiscoverJesusMessage: String
    
    static var emptyValue: OnboardingTutorialStringsDomainModel {
        return OnboardingTutorialStringsDomainModel(chooseAppLanguageButtonTitle: "", beginTutorialButtonTitle: "", nextTutorialPageButtonTitle: "", endTutorialButtonTitle: "", readyForEveryConversationTitle: "", readyForEveryConversationVideoLinkTitle: "", prepareForMomentsThatMatterTitle: "", prepareForMomentsThatMatterMessage: "", talkWithGodAboutAnyoneTitle: "", talkWithGodAboutAnyoneMessage: "", helpSomeoneDiscoverJesusTitle: "", helpSomeoneDiscoverJesusMessage: "")
    }
}
