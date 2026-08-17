//
//  GetLocalizationSettingsConfirmationStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetLocalizationSettingsConfirmationStringsUseCase: Sendable {

    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }

    func execute(appLanguage: AppLanguageDomainModel, selectedCountry: LocalizationSettingsCountryListItem) -> LocalizationSettingsConfirmationStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.localizationSettingsConfirmationTitle.key
        let titleNoCountryKey: String = LocalizableStringKeys.localizationSettingsConfirmationTitleNoCountry.key
        let descriptionKey: String = LocalizableStringKeys.localizationSettingsConfirmationDescription.key
        let detailKey: String = LocalizableStringKeys.localizationSettingsConfirmationDetail.key
        let cancelButtonKey: String = LocalizableStringKeys.localizationSettingsConfirmationCancelButton.key
        let confirmButtonKey: String = LocalizableStringKeys.localizationSettingsConfirmationConfirmButton.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                titleNoCountryKey,
                descriptionKey,
                detailKey,
                cancelButtonKey,
                confirmButtonKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let titleHighlightModel: ConfirmAppLanguageHighlightStringDomainModel

        switch selectedCountry {
        case .country(let country):
            let titleTemplate: String = strings[titleKey] ?? ""
            let countryName = country.countryNameTranslatedInCurrentAppLanguage
            let titleFullText = String(format: titleTemplate, countryName)
            titleHighlightModel = ConfirmAppLanguageHighlightStringDomainModel(
                fullText: titleFullText,
                highlightText: countryName
            )

        case .preferNotToSay:
            let titleFullText: String = strings[titleNoCountryKey] ?? ""
            titleHighlightModel = ConfirmAppLanguageHighlightStringDomainModel(
                fullText: titleFullText,
                highlightText: ""
            )
        }

        return LocalizationSettingsConfirmationStringsDomainModel(
            titleHighlightModel: titleHighlightModel,
            description: strings[descriptionKey] ?? "",
            detail: strings[detailKey] ?? "",
            cancelButton: strings[cancelButtonKey] ?? "",
            confirmButton: strings[confirmButtonKey] ?? ""
        )
    }
}
