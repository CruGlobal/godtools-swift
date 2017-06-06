//
//  GTNotifications.swift
//  godtools
//
//  Created by Devserker on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let displayMenuNotification = Notification.Name("displayMenuNotificationName")
    static let dismissMenuNotification = Notification.Name("dismissMenuNotificationName")
    static let presentLanguageSettingsNotification = Notification.Name("presentLanguageSettingsNotificationName")
    static let moveToPageNotification = Notification.Name("moveToPageNotification")
    static let moveToNextPageNotification = Notification.Name("moveToNextPageNotification")
    static let downloadProgressViewUpdateNotification = Notification.Name("downloadProgressViewUpdateNotification")
    static let downloadPrimaryTranslationCompleteNotification = Notification.Name("downloadPrimaryTranslationCompleteNotification")
    static let initialAppStateCleanupCompleted = Notification.Name("initialAppStateCleanupCompleted")
    static let downloadBannerCompleteNotifciation = Notification.Name("downloadBannerCompleteNotifciation")
    static let sendEmailFromTractForm = Notification.Name("sendEmailFromTractForm")
}
