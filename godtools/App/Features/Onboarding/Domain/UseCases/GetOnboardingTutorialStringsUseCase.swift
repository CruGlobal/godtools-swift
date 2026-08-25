//
//  GetOnboardingTutorialStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetOnboardingTutorialStringsUseCase: Sendable {
    
    private let localizationServices: LocalizationServicesInterface
    
    init(localizationServices: LocalizationServicesInterface) {
        
        self.localizationServices = localizationServices
    }
    
    func execute(appLanguage: AppLanguageDomainModel) -> OnboardingTutorialStringsDomainModel {
        
        let skipActionTitleKey: String = LocalizableStringKeys.navigationBarNavigationItemSkip.key
        let chooseAppLanguageButtonTitleKey: String = LocalizableStringKeys.onboardingTutorialChooseLanguageButtonTitle.key
        let beginTutorialButtonTitleKey: String = LocalizableStringKeys.onboardingTutorialBeginButtonTitle.key
        let nextTutorialPageButtonTitleKey: String = LocalizableStringKeys.onboardingTutorialNextButtonTitle.key
        let endTutorialButtonTitleKey: String = LocalizableStringKeys.onboardingTutorialGetStartedButtonTitle.key
        let readyForEveryConversationTitleKey: String = LocalizableStringKeys.onboardingTutorial0Title.key
        let readyForEveryConversationVideoLinkTitleKey: String = LocalizableStringKeys.onboardingTutorial0VideoLinkTitle.key
        let prepareForMomentsThatMatterTitleKey: String = LocalizableStringKeys.onboardingTutorial2Title.key
        let prepareForMomentsThatMatterMessageKey: String = LocalizableStringKeys.onboardingTutorial2Message.key
        let talkWithGodAboutAnyoneTitleKey: String = LocalizableStringKeys.onboardingTutorial1Title.key
        let talkWithGodAboutAnyoneMessageKey: String = LocalizableStringKeys.onboardingTutorial1Message.key
        let helpSomeoneDiscoverJesusTitleKey: String = LocalizableStringKeys.onboardingTutorial3Title.key
        let helpSomeoneDiscoverJesusMessageKey: String = LocalizableStringKeys.onboardingTutorial3Message.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                skipActionTitleKey,
                chooseAppLanguageButtonTitleKey,
                beginTutorialButtonTitleKey,
                nextTutorialPageButtonTitleKey,
                endTutorialButtonTitleKey,
                readyForEveryConversationTitleKey,
                readyForEveryConversationVideoLinkTitleKey,
                prepareForMomentsThatMatterTitleKey,
                prepareForMomentsThatMatterMessageKey,
                talkWithGodAboutAnyoneTitleKey,
                talkWithGodAboutAnyoneMessageKey,
                helpSomeoneDiscoverJesusTitleKey,
                helpSomeoneDiscoverJesusMessageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return OnboardingTutorialStringsDomainModel(
            skipActionTitle: strings[skipActionTitleKey] ?? "",
            chooseAppLanguageButtonTitle: strings[chooseAppLanguageButtonTitleKey] ?? "",
            beginTutorialButtonTitle: strings[beginTutorialButtonTitleKey] ?? "",
            nextTutorialPageButtonTitle: strings[nextTutorialPageButtonTitleKey] ?? "",
            endTutorialButtonTitle: strings[endTutorialButtonTitleKey] ?? "",
            readyForEveryConversationTitle: strings[readyForEveryConversationTitleKey] ?? "",
            readyForEveryConversationVideoLinkTitle: strings[readyForEveryConversationVideoLinkTitleKey] ?? "",
            prepareForMomentsThatMatterTitle: strings[prepareForMomentsThatMatterTitleKey] ?? "",
            prepareForMomentsThatMatterMessage: strings[prepareForMomentsThatMatterMessageKey] ?? "",
            talkWithGodAboutAnyoneTitle: strings[talkWithGodAboutAnyoneTitleKey] ?? "",
            talkWithGodAboutAnyoneMessage: strings[talkWithGodAboutAnyoneMessageKey] ?? "",
            helpSomeoneDiscoverJesusTitle: strings[helpSomeoneDiscoverJesusTitleKey] ?? "",
            helpSomeoneDiscoverJesusMessage: strings[helpSomeoneDiscoverJesusMessageKey] ?? ""
        )
    }
}
