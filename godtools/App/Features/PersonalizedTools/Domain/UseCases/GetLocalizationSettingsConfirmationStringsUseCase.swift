//
//  GetLocalizationSettingsConfirmationStringsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

class GetLocalizationSettingsConfirmationStringsUseCase {

    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {
        self.localizationServices = localizationServices
    }

    func execute(appLanguage: AppLanguageDomainModel, selectedCountry: LocalizationSettingsCountryListItemDomainModel) -> AnyPublisher<LocalizationSettingsConfirmationStringsDomainModel, Never> {

        let titleHighlightModel: ConfirmAppLanguageHighlightStringDomainModel

        if selectedCountry.isoRegionCode.isEmpty {
            
            let titleFullText = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.titleNoCountry")
            titleHighlightModel = ConfirmAppLanguageHighlightStringDomainModel(
                fullText: titleFullText,
                highlightText: ""
            )
            
        } else {
            let titleTemplate = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.title")
            let countryName = selectedCountry.countryNameTranslatedInCurrentAppLanguage
            let titleFullText = String(format: titleTemplate, countryName)
            titleHighlightModel = ConfirmAppLanguageHighlightStringDomainModel(
                fullText: titleFullText,
                highlightText: countryName
            )
        }

        let interfaceStrings = LocalizationSettingsConfirmationStringsDomainModel(
            titleHighlightModel: titleHighlightModel,
            description: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.description"),
            detail: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.detail"),
            cancelButton: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.cancelButton"),
            confirmButton: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: "localizationSettings.confirmation.confirmButton")
        )

        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
