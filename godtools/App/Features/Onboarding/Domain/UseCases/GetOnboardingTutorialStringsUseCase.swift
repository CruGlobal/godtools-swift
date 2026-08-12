//
//  GetOnboardingTutorialStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetOnboardingTutorialStringsUseCase {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async -> OnboardingTutorialStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = OnboardingTutorialStringsDomainModel(
            chooseAppLanguageButtonTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorialChooseLanguageButtonTitle.key),
            beginTutorialButtonTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorialBeginButtonTitle.key),
            nextTutorialPageButtonTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorialNextButtonTitle.key),
            endTutorialButtonTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorialGetStartedButtonTitle.key),
            readyForEveryConversationTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial0Title.key),
            readyForEveryConversationVideoLinkTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial0VideoLinkTitle.key),
            prepareForMomentsThatMatterTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial2Title.key),
            prepareForMomentsThatMatterMessage: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial2Message.key),
            talkWithGodAboutAnyoneTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial1Title.key),
            talkWithGodAboutAnyoneMessage: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial1Message.key),
            helpSomeoneDiscoverJesusTitle: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial3Title.key),
            helpSomeoneDiscoverJesusMessage: await localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial3Message.key)
        )
        
        return strings
    }
}
