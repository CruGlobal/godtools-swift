//
//  GetOptInNotificationInterfaceStringsRepository.swift
//  godtools
//
//  Created by Jason Bennett on 3/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import LocalizationServices

class GetOptInNotificationInterfaceStringsRepository: GetOptInNotificationInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices

    init(localizationServices: LocalizationServices) {

        self.localizationServices = localizationServices
    }

    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<OptInNotificationInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = OptInNotificationInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: translateInLanguage, key: "optInNotification.title"),
            body: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: translateInLanguage, key: "optInNotification.body"),
            allowNotificationsActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: translateInLanguage, key: "optInNotification.allowNotifications"),
            notificationSettingsActionTitle: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: translateInLanguage, key: "optInNotification.notificationSettings"),
            maybeLaterActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: translateInLanguage, key: "optInNotification.maybeLater")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }

}
