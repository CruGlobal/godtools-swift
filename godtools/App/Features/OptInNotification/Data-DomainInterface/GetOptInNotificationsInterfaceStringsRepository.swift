//
//  GetOptInNotificationsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Jason Bennett on 3/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import LocalizationServices

class GetOptInNotificationsInterfaceStringsRepository:
    GetOptInNotificationsInterfaceStringsRepositoryInterface
{
    private let localizationServices: LocalizationServices

    init(localizationServices: LocalizationServices) {

        self.localizationServices = localizationServices
    }

    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel)
        -> AnyPublisher<OptInNotificationsStringsDomainModel, Never>
    {
        let interfaceStrings = OptInNotificationsStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: translateInLanguage, key: "optInNotifications.title"),
            body: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: translateInLanguage, key: "optInNotifications.body"),
            allowNotificationsActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: translateInLanguage, key: "optInNotifications.allowNotifications"),
            maybeLaterActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: translateInLanguage, key: "optInNotifications.maybeLater")
        )
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }

}
