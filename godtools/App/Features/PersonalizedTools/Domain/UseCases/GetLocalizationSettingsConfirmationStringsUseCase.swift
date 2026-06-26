//
//  GetLocalizationSettingsConfirmationStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetLocalizationSettingsConfirmationStringsUseCase {

    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }

    func execute(appLanguage: AppLanguageDomainModel, selectedCountry: LocalizationSettingsCountryListItem) -> AnyPublisher<LocalizationSettingsConfirmationStringsDomainModel, Never> {

        let titleHighlightModel: ConfirmAppLanguageHighlightStringDomainModel

        switch selectedCountry {
        case .country(let country):
            let titleTemplate = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.localizationSettingsConfirmationTitle.key)
            let countryName = country.countryNameTranslatedInCurrentAppLanguage
            let titleFullText = String(format: titleTemplate, countryName)
            titleHighlightModel = ConfirmAppLanguageHighlightStringDomainModel(
                fullText: titleFullText,
                highlightText: countryName
            )

        case .preferNotToSay:
            let titleFullText = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.localizationSettingsConfirmationTitleNoCountry.key)
            titleHighlightModel = ConfirmAppLanguageHighlightStringDomainModel(
                fullText: titleFullText,
                highlightText: ""
            )
        }

        let strings = LocalizationSettingsConfirmationStringsDomainModel(
            titleHighlightModel: titleHighlightModel,
            description: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.localizationSettingsConfirmationDescription.key),
            detail: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.localizationSettingsConfirmationDetail.key),
            cancelButton: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.localizationSettingsConfirmationCancelButton.key),
            confirmButton: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.localizationSettingsConfirmationConfirmButton.key)
        )

        return Just(strings)
            .eraseToAnyPublisher()
    }
}
