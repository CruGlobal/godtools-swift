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
    static let moveToPageNotification = Notification.Name("moveToPageNotification")
    static let moveToNextPageNotification = Notification.Name("moveToNextPageNotification")
    static let moveToPreviousPageNotification = Notification.Name("moveToPreviousPageNotification")
    static let downloadProgressViewUpdateNotification = Notification.Name("downloadProgressViewUpdateNotification")
    static let downloadPrimaryTranslationCompleteNotification = Notification.Name("downloadPrimaryTranslationCompleteNotification")
    static let downloadBannerCompleteNotifciation = Notification.Name("downloadBannerCompleteNotifciation")
    static let sendEmailFromTractForm = Notification.Name("sendEmailFromTractForm")
    static let reloadHomeListNotification = Notification.Name("reloadHomeListNotification")
    
    static let screenViewNotification = Notification.Name("screenViewNotification")
    static let actionTrackNotification = Notification.Name("actionTrackNotification")
    static let heroActionTrackNotification = Notification.Name("heroActionTrackNotification")
    static let heroTimedActionNotification = Notification.Name("heroTimedActionNotification")
    static let tractCardStateChangedNotification = Notification.Name("tractCardStateChanged")

}
