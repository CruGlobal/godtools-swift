//
//  GetOptInNotificationStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetOptInNotificationStringsUseCase {

    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {

        self.localizationServices = localizationServices
    }

    func execute(appLanguage: AppLanguageDomainModel) -> OptInNotificationStringsDomainModel {
        
        let strings = OptInNotificationStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationTitle.key),
            body: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationBody.key),
            allowNotificationsActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationAllowNotifications.key),
            notificationSettingsActionTitle: localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationNotificationSettings.key),
            maybeLaterActionTitle:
                localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationMaybeLater.key)
        )
        
        return strings
    }
}
