//
//  GetOptInDialogInterfaceStringsRepository.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import LocalizationServices

class GetOptInDialogInterfaceStringsRepository:
    GetOptInDialogInterfaceStringsRepositoryInterface
{
    private let localizationServices: LocalizationServices

    init(localizationServices: LocalizationServices) {
        self.localizationServices = localizationServices
    }

    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel)
    -> AnyPublisher<OptInDialogInterfaceStringsDomainModel, Never>
    {
        let interfaceStrings = OptInDialogInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: translateInLanguage, key: "optInDialog.title"),
            body: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: translateInLanguage, key: "optInDialog.body"),
            cancelActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: translateInLanguage, key: "optInDialog.cancel"),
            settingsActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: translateInLanguage, key: "optInDialog.settings")
        )
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }

}
