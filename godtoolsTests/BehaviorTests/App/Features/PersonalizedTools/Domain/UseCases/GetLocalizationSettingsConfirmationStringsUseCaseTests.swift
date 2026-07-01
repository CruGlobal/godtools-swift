//
//  GetLocalizationSettingsConfirmationStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetLocalizationSettingsConfirmationStringsUseCaseTests {

    private let countryName: String = "United States"

    @Test(
        """
        Given: User has selected a country in the localization settings.
        When: The localization settings confirmation strings are requested for an app language.
        Then: The title is formatted with the selected country name and the remaining strings are localized.
        """
    )
    func titleContainsTheSelectedCountryName() async {

        let useCase = getUseCase()

        let selectedCountry: LocalizationSettingsCountryListItem = .country(
            LocalizationSettingsCountryDomainModel(
                isoRegionCode: "US",
                countryNameTranslatedInCurrentAppLanguage: countryName
            )
        )

        let strings: LocalizationSettingsConfirmationStringsDomainModel = useCase.execute(
            appLanguage: LanguageCodeDomainModel.english.value,
            selectedCountry: selectedCountry
        )

        #expect(strings.titleHighlightModel.fullText == "Tools for \(countryName)")
        #expect(strings.titleHighlightModel.highlightText == countryName)
        #expect(strings.description == "en:\(LocalizableStringKeys.localizationSettingsConfirmationDescription.key)")
        #expect(strings.detail == "en:\(LocalizableStringKeys.localizationSettingsConfirmationDetail.key)")
        #expect(strings.cancelButton == "en:\(LocalizableStringKeys.localizationSettingsConfirmationCancelButton.key)")
        #expect(strings.confirmButton == "en:\(LocalizableStringKeys.localizationSettingsConfirmationConfirmButton.key)")
    }

    @Test(
        """
        Given: User has selected prefer not to say in the localization settings.
        When: The localization settings confirmation strings are requested for an app language.
        Then: The title uses the no country title and has no highlighted text.
        """
    )
    func titleUsesNoCountryTitleWhenPreferNotToSay() async {

        let useCase = getUseCase()

        let selectedCountry: LocalizationSettingsCountryListItem = .preferNotToSay(
            LocalizationSettingsPreferNotToSayDomainModel(preferNotToSayText: "Prefer not to say")
        )

        let strings: LocalizationSettingsConfirmationStringsDomainModel = useCase.execute(
            appLanguage: LanguageCodeDomainModel.english.value,
            selectedCountry: selectedCountry
        )

        #expect(strings.titleHighlightModel.fullText == "en:\(LocalizableStringKeys.localizationSettingsConfirmationTitleNoCountry.key)")
        #expect(strings.titleHighlightModel.highlightText == "")
    }
}

extension GetLocalizationSettingsConfirmationStringsUseCaseTests {

    private func getUseCase() -> GetLocalizationSettingsConfirmationStringsUseCase {

        let localizableStrings: [String: [String: String]] = [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.localizationSettingsConfirmationTitle.key: "Tools for %@",
                LocalizableStringKeys.localizationSettingsConfirmationTitleNoCountry.key: "en:\(LocalizableStringKeys.localizationSettingsConfirmationTitleNoCountry.key)",
                LocalizableStringKeys.localizationSettingsConfirmationDescription.key: "en:\(LocalizableStringKeys.localizationSettingsConfirmationDescription.key)",
                LocalizableStringKeys.localizationSettingsConfirmationDetail.key: "en:\(LocalizableStringKeys.localizationSettingsConfirmationDetail.key)",
                LocalizableStringKeys.localizationSettingsConfirmationCancelButton.key: "en:\(LocalizableStringKeys.localizationSettingsConfirmationCancelButton.key)",
                LocalizableStringKeys.localizationSettingsConfirmationConfirmButton.key: "en:\(LocalizableStringKeys.localizationSettingsConfirmationConfirmButton.key)"
            ]
        ]

        return GetLocalizationSettingsConfirmationStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)
        )
    }
}
