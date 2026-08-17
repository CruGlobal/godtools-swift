//
//  GetOptInNotificationStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class GetOptInNotificationStringsUseCase: Sendable {

    private let localizationServices: LocalizationServicesInterface

    init(localizationServices: LocalizationServicesInterface) {

        self.localizationServices = localizationServices
    }

    func execute(appLanguage: AppLanguageDomainModel) -> OptInNotificationStringsDomainModel {

        let titleKey: String = LocalizableStringKeys.optInNotificationTitle.key
        let bodyKey: String = LocalizableStringKeys.optInNotificationBody.key
        let allowNotificationsActionTitleKey: String = LocalizableStringKeys.optInNotificationAllowNotifications.key
        let notificationSettingsActionTitleKey: String = LocalizableStringKeys.optInNotificationNotificationSettings.key
        let maybeLaterActionTitleKey: String = LocalizableStringKeys.optInNotificationMaybeLater.key

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                titleKey,
                bodyKey,
                allowNotificationsActionTitleKey,
                notificationSettingsActionTitleKey,
                maybeLaterActionTitleKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return OptInNotificationStringsDomainModel(
            title: strings[titleKey] ?? "",
            body: strings[bodyKey] ?? "",
            allowNotificationsActionTitle: strings[allowNotificationsActionTitleKey] ?? "",
            notificationSettingsActionTitle: strings[notificationSettingsActionTitleKey] ?? "",
            maybeLaterActionTitle: strings[maybeLaterActionTitleKey] ?? ""
        )
    }
}
