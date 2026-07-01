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
    
    func execute(appLanguage: AppLanguageDomainModel) -> OnboardingTutorialStringsDomainModel {
        
        let localeId: String = appLanguage
        
        let strings = OnboardingTutorialStringsDomainModel(
            chooseAppLanguageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorialChooseLanguageButtonTitle.key),
            beginTutorialButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorialBeginButtonTitle.key),
            nextTutorialPageButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorialNextButtonTitle.key),
            endTutorialButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorialGetStartedButtonTitle.key),
            readyForEveryConversationTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial0Title.key),
            readyForEveryConversationVideoLinkTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial0VideoLinkTitle.key),
            prepareForMomentsThatMatterTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial2Title.key),
            prepareForMomentsThatMatterMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial2Message.key),
            talkWithGodAboutAnyoneTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial1Title.key),
            talkWithGodAboutAnyoneMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial1Message.key),
            helpSomeoneDiscoverJesusTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial3Title.key),
            helpSomeoneDiscoverJesusMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: LocalizableStringKeys.onboardingTutorial3Message.key)
        )
        
        return strings
    }
}
