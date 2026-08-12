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

    func execute(appLanguage: AppLanguageDomainModel) async -> OptInNotificationStringsDomainModel {
        
        let strings = OptInNotificationStringsDomainModel(
            title: await localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationTitle.key),
            body: await localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationBody.key),
            allowNotificationsActionTitle:
                await localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationAllowNotifications.key),
            notificationSettingsActionTitle: await localizationServices.stringForLocaleElseEnglish(
                localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationNotificationSettings.key),
            maybeLaterActionTitle:
                await localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage, key: LocalizableStringKeys.optInNotificationMaybeLater.key)
        )
        
        return strings
    }
}
