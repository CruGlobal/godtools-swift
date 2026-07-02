//
//  GetToolsStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetToolsStringsUseCaseTests {

    struct TestArgument {
        let translateInLanguage: AppLanguageDomainModel
    }

    @Test(
        """
        Given: User is viewing the tools.
        When: The tools strings are requested for an app language.
        Then: Each string is localized for the requested app language.
        """,
        arguments: [
            TestArgument(translateInLanguage: LanguageCodeDomainModel.english.value),
            TestArgument(translateInLanguage: LanguageCodeDomainModel.spanish.value)
        ]
    )
    func stringsAreLocalizedForTheRequestedAppLanguage(argument: TestArgument) async {

        let useCase = getUseCase()

        let strings: ToolsStringsDomainModel = useCase.execute(translateInLanguage: argument.translateInLanguage)

        #expect(strings.favoritingToolBannerMessage == "\(argument.translateInLanguage):\(LocalizableStringKeys.toolOfflineFavoriteMessage.key)")
        #expect(strings.toolSpotlightTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.toolsSpotlightTitle.key)")
        #expect(strings.toolSpotlightSubtitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.toolsSpotlightSubtitle.key)")
        #expect(strings.filterTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.toolsFilterSectionTitle.key)")
        #expect(strings.personalizedToolToggleTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedToolTogglePersonalizedTitle.key)")
        #expect(strings.allToolsToggleTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedToolToggleAllToolsTitle.key)")
        #expect(strings.personalizedToolExplanationTitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedToolFooterTitle.key)")
        #expect(strings.personalizedToolExplanationSubtitle == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedToolFooterSubtitle.key)")
        #expect(strings.changePersonalizedToolSettingsAction == "\(argument.translateInLanguage):\(LocalizableStringKeys.dashboardPersonalizedToolFooterButtonTitle.key)")
        #expect(strings.viewAllToolsAction == "\(argument.translateInLanguage):\(LocalizableStringKeys.toolsPersonalizationUnavailableViewAllTools.key)")
    }
}

extension GetToolsStringsUseCaseTests {

    private func getUseCase() -> GetToolsStringsUseCase {

        let stringKeys: [LocalizableStringKeys] = [
            .toolOfflineFavoriteMessage, .toolsSpotlightTitle, .toolsSpotlightSubtitle, .toolsFilterSectionTitle,
            .dashboardPersonalizedToolTogglePersonalizedTitle, .dashboardPersonalizedToolToggleAllToolsTitle,
            .dashboardPersonalizedToolFooterTitle, .dashboardPersonalizedToolFooterSubtitle,
            .dashboardPersonalizedToolFooterButtonTitle, .toolsPersonalizationUnavailableViewAllTools
        ]

        return GetToolsStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: MockLocalizationServices.getStrings(stringKeys: stringKeys, languages: [.english, .spanish]))
        )
    }
}
