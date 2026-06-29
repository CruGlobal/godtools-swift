//
//  GetConfirmAppLanguageStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetConfirmAppLanguageStringsUseCaseTests {

    private let englishAppLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    private let spanishAppLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.spanish.value

    @Test(
        """
        Given: User has selected a new app language to confirm.
        When: The confirm app language strings are requested while the current app language is english.
        Then: The newly selected language message is translated in the selected language and the current language message is translated in the current app language, each highlighting the selected language name.
        """
    )
    func messagesAreTranslatedAndHighlightTheSelectedLanguageName() async {

        let useCase = getUseCase()

        let strings: ConfirmAppLanguageStringsDomainModel = useCase.execute(
            appLanguage: englishAppLanguage,
            selectedLanguage: spanishAppLanguage
        )

        #expect(strings.messageInNewlySelectedLanguageHighlightModel.fullText == "Has seleccionado Español")
        #expect(strings.messageInNewlySelectedLanguageHighlightModel.highlightText == "Español")
        #expect(strings.messageInCurrentLanguageHighlightModel.fullText == "You selected Spanish")
        #expect(strings.messageInCurrentLanguageHighlightModel.highlightText == "Spanish")
        #expect(strings.changeLanguageButtonText == "en:\(LocalizableStringKeys.languageSettingsConfirmAppLanguageChangeLanguageButtonTitle.key)")
        #expect(strings.nevermindButtonText == "en:\(LocalizableStringKeys.languageSettingsConfirmAppLanguageNevermindButtonTitle.key)")
    }
}

extension GetConfirmAppLanguageStringsUseCaseTests {

    private func getUseCase() -> GetConfirmAppLanguageStringsUseCase {

        let localizableStrings: [String: [String: String]] = [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.languageSettingsConfirmAppLanguageMessage.key: "You selected %@",
                LocalizableStringKeys.languageSettingsConfirmAppLanguageChangeLanguageButtonTitle.key: "en:\(LocalizableStringKeys.languageSettingsConfirmAppLanguageChangeLanguageButtonTitle.key)",
                LocalizableStringKeys.languageSettingsConfirmAppLanguageNevermindButtonTitle.key: "en:\(LocalizableStringKeys.languageSettingsConfirmAppLanguageNevermindButtonTitle.key)"
            ],
            LanguageCodeDomainModel.spanish.value: [
                LocalizableStringKeys.languageSettingsConfirmAppLanguageMessage.key: "Has seleccionado %@",
                LocalizableStringKeys.languageSettingsConfirmAppLanguageChangeLanguageButtonTitle.key: "es:\(LocalizableStringKeys.languageSettingsConfirmAppLanguageChangeLanguageButtonTitle.key)",
                LocalizableStringKeys.languageSettingsConfirmAppLanguageNevermindButtonTitle.key: "es:\(LocalizableStringKeys.languageSettingsConfirmAppLanguageNevermindButtonTitle.key)"
            ]
        ]

        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageName: MockLocalizationLanguageNameRepository(localizationServices: MockLocalizationServices.createLanguageNamesLocalizationServices()),
            localeLanguageName: MockLocaleLanguageName.defaultMockLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )

        return GetConfirmAppLanguageStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings),
            getTranslatedLanguageName: getTranslatedLanguageName
        )
    }
}
