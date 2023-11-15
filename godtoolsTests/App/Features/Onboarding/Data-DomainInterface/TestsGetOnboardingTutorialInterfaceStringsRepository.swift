//
//  TestsGetOnboardingTutorialInterfaceStringsRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetOnboardingTutorialInterfaceStringsRepository: GetOnboardingTutorialInterfaceStringsRepositoryInterface {
    
    init() {
        
    }
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings: OnboardingTutorialInterfaceStringsDomainModel
        
        if appLanguage == LanguageCodeDomainModel.english.value {
            
            interfaceStrings = getEnglishInterfaceStrings()
        }
        else if appLanguage == LanguageCodeDomainModel.spanish.rawValue {
            
            interfaceStrings = getSpanishInterfaceStrings()
        }
        else {
            
            interfaceStrings = getEnglishInterfaceStrings()
        }
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
    
    private func getEnglishInterfaceStrings() -> OnboardingTutorialInterfaceStringsDomainModel {
        
        return OnboardingTutorialInterfaceStringsDomainModel(
            chooseAppLanguageButtonTitle: "Choose Language",
            beginTutorialButtonTitle: "Begin",
            nextTutorialPageButtonTitle: "",
            readyForEveryConversationTitle: "",
            readyForEveryConversationVideoLinkTitle: "",
            prepareForMomentsThatMatterTitle: "",
            prepareForMomentsThatMatterMessage: "",
            talkWithGodAboutAnyoneTitle: "",
            talkWithGodAboutAnyoneMessage: "",
            helpSomeoneDiscoverJesusTitle: "",
            helpSomeoneDiscoverJesusMessage: ""
        )
    }
    
    private func getSpanishInterfaceStrings() -> OnboardingTutorialInterfaceStringsDomainModel {
        
        return OnboardingTutorialInterfaceStringsDomainModel(
            chooseAppLanguageButtonTitle: "Elige lengua",
            beginTutorialButtonTitle: "Comenzar",
            nextTutorialPageButtonTitle: "",
            readyForEveryConversationTitle: "",
            readyForEveryConversationVideoLinkTitle: "",
            prepareForMomentsThatMatterTitle: "",
            prepareForMomentsThatMatterMessage: "",
            talkWithGodAboutAnyoneTitle: "",
            talkWithGodAboutAnyoneMessage: "",
            helpSomeoneDiscoverJesusTitle: "",
            helpSomeoneDiscoverJesusMessage: ""
        )
    }
}
