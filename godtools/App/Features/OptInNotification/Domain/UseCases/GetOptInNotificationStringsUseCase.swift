//
//  GetOptInNotificationStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetOptInNotificationStringsUseCase {

    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {

        self.localizationServices = localizationServices
    }

    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<OptInNotificationStringsDomainModel, Never> {
        
        let strings = OptInNotificationStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage, key: "optInNotification.title"),
            body: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage, key: "optInNotification.body"),
            allowNotificationsActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage, key: "optInNotification.allowNotifications"),
            notificationSettingsActionTitle: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage, key: "optInNotification.notificationSettings"),
            maybeLaterActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage, key: "optInNotification.maybeLater")
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
