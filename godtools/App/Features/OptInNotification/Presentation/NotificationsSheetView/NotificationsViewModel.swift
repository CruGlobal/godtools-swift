//
//  NotificationsViewModel.swift
//  godtools
//
//  Created by Jason Bennett on 3/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import BottomSheet
import Combine
import Foundation
import UserNotifications

class NotificationsViewModel: ObservableObject {

    private let viewOptInNotificationsUseCase: ViewOptInNotificationsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase

    @Published var isNotificationPermissionGranted: Bool = false
    @Published var showSettingsAlert: Bool = false

    @Published var bottomSheetPosition: BottomSheetPosition = .hidden

    init(
        viewOptInNotificationsUseCase: ViewOptInNotificationsUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    ) {
        self.viewOptInNotificationsUseCase = viewOptInNotificationsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase

        // do language translation stuff
    }

    deinit {
        print("x deinit: \(type(of: self))")
    }

    //    do analytics stuff\

    //    private var analyticsScreenName: String {
    //        return "Favorites"
    //    }
    //
    //    private var analyticsSiteSection: String {
    //        return "home"
    //    }
    //
    //    private var analyticsSiteSubSection: String {
    //        return ""
    //    }

    //    func requestNotificationPermission() async {
    //        let granted = await withCheckedContinuation { continuation in
    //            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
    //                continuation.resume(returning: granted)
    //            }
    //        }
    //        // Update published properties based on the result.
    //        if granted {
    //            DispatchQueue.main.async {
    //                self.isNotificationPermissionGranted = true
    //            }
    //        } else {
    //            // Trigger UI to show alert using SwiftUI's .alert modifier.
    //            DispatchQueue.main.async {
    //                self.showSettingsAlert = true
    //            }
    //        }
    //    }
    //
    //    func openSettings() {
    //        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
    //        UIApplication.shared.open(settingsURL)
    //    }
}

// MARK: - Inputs

extension NotificationsViewModel {

    //user gestures

    //Allow Notifications button

    //Maybe Later button
}
