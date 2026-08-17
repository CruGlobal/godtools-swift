//
//  GetOnboardingTutorialStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetOnboardingTutorialStringsUseCaseTests {

    struct TestArgument {
        let appLanguage: AppLanguageDomainModel
    }

    private static let stringKeys: [LocalizableStringKeys] = [
        .onboardingTutorialChooseLanguageButtonTitle, .onboardingTutorialBeginButtonTitle,
        .onboardingTutorialNextButtonTitle, .onboardingTutorialGetStartedButtonTitle,
        .onboardingTutorial0Title, .onboardingTutorial0VideoLinkTitle,
        .onboardingTutorial2Title, .onboardingTutorial2Message,
        .onboardingTutorial1Title, .onboardingTutorial1Message,
        .onboardingTutorial3Title, .onboardingTutorial3Message
    ]

    @Test(
        """
        Given: User is viewing the onboarding tutorial.
        When: The onboarding tutorial strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(appLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(appLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) {

        let useCase = getUseCase()

        let strings: OnboardingTutorialStringsDomainModel = useCase.execute(appLanguage: argument.appLanguage)

        #expect(strings.chooseAppLanguageButtonTitle == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorialChooseLanguageButtonTitle.key)")
        #expect(strings.beginTutorialButtonTitle == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorialBeginButtonTitle.key)")
        #expect(strings.nextTutorialPageButtonTitle == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorialNextButtonTitle.key)")
        #expect(strings.endTutorialButtonTitle == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorialGetStartedButtonTitle.key)")
        #expect(strings.readyForEveryConversationTitle == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorial0Title.key)")
        #expect(strings.readyForEveryConversationVideoLinkTitle == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorial0VideoLinkTitle.key)")
        #expect(strings.prepareForMomentsThatMatterTitle == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorial2Title.key)")
        #expect(strings.prepareForMomentsThatMatterMessage == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorial2Message.key)")
        #expect(strings.talkWithGodAboutAnyoneTitle == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorial1Title.key)")
        #expect(strings.talkWithGodAboutAnyoneMessage == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorial1Message.key)")
        #expect(strings.helpSomeoneDiscoverJesusTitle == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorial3Title.key)")
        #expect(strings.helpSomeoneDiscoverJesusMessage == "\(argument.appLanguage):\(LocalizableStringKeys.onboardingTutorial3Message.key)")
    }
}

extension GetOnboardingTutorialStringsUseCaseTests {

    private func getUseCase() -> GetOnboardingTutorialStringsUseCase {

        return GetOnboardingTutorialStringsUseCase(
            localizationServices: FakeLocalizationServices(localizableStrings: FakeLocalizationServices.getStrings(stringKeys: Self.stringKeys, languages: [.english, .spanish]))
        )
    }
}
