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
import UIKit
import UserNotifications

class NotificationsViewModel: ObservableObject {

    private let viewOptInNotificationsUseCase: ViewOptInNotificationsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase

    private var notificationStatus: String = ""
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue

    @Published var bottomSheetPosition: BottomSheetPosition = .hidden
    
    @Published var title: String = ""
    @Published var body: String = ""
    @Published var allowNotificationsActionTitle: String = ""
    @Published var maybeLaterActionTitle: String = ""

    init(
        viewOptInNotificationsUseCase: ViewOptInNotificationsUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    ) {
        self.viewOptInNotificationsUseCase = viewOptInNotificationsUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase

        // do language translation stuff

        Task {
            self.notificationStatus = await checkNotificationStatus()
        }
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .flatMap { appLanguage in viewOptInNotificationsUseCase.viewPublisher(appLanguage: appLanguage)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewOptInNotificationsDomainModel) in
                self?.title = domainModel.interfaceStrings.title
                self?.body = domainModel.interfaceStrings.body
                self?.allowNotificationsActionTitle = domainModel.interfaceStrings.allowNotificationsActionTitle
                self?.maybeLaterActionTitle = domainModel.interfaceStrings.maybeLaterActionTitle
               
            }
            .store(in: &cancellables)
    }

    deinit {
        print("x deinit: \(type(of: self))")
    }
//DOMAIN LAYER
    func requestNotificationPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [
                .alert, .badge, .sound,
            ]) { granted, error in

                continuation.resume(returning: granted)
            }
        }
    }

    func showSettingsAlert(completion: @escaping () -> Void) {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString)
        else { return }

        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene,
                let rootViewController = windowScene.windows.first?
                    .rootViewController
            {

                let alert = UIAlertController(
                    title: "Enable Notifications",
                    message:
                        "Notifications are disabled. Please enable them in Settings.",
                    preferredStyle: .alert
                )

                alert.addAction(
                    UIAlertAction(title: "Settings", style: .default) { _ in
                        UIApplication.shared.open(
                            settingsURL, options: [:], completionHandler: nil)
                        // Invoke the completion handler after the alert action
                        completion()
                    })

                alert.addAction(
                    UIAlertAction(title: "Cancel", style: .cancel) { _ in
                        completion()
                    })

                rootViewController.present(
                    alert, animated: true, completion: nil)
            }

        }
    }

    func checkNotificationStatus() async -> String {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            print("NotificationStatus: Enabled")
            return "Enabled"
        case .denied:
            print("NotificationStatus: Denied")
            return
                "Denied"
        case .notDetermined:
            print("NotificationStatus: Undetermined")
            return "Undetermined"
        @unknown default:
            return "Unknown"
        }
    }

    func recordLastPrompt() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        guard let testDate = dateFormatter.date(from: "01/01/2025") else {
            print("Failed to create date from string.")
            return
        }

        let dateString = dateFormatter.string(from: testDate)
        //DATA LAYER
        UserDefaults.standard.set(dateString, forKey: "lastPrompted")
        print("set lastPrompted to: \(dateString)")
    }

    func shouldPromptNotificationsSheet() async {

        notificationStatus = await checkNotificationStatus()

        // Retrieve lastPrompted date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        //DATA LAYER
        let lastPrompted = UserDefaults.standard.string(
            forKey: "lastPrompted")
        let lastPromptedDate =
            lastPrompted.flatMap {
                dateFormatter.date(from: $0)
            } ?? Date.distantPast

        // Get current date
        let currentDate = Date()
        let calendar = Calendar.current
        let twoMonthsAgo = calendar.date(
            byAdding: .month, value: -2, to: currentDate)!

        if notificationStatus != "Approved" {
            if notificationStatus == "Undetermined" {
                print("Detected undetermined status")
                bottomSheetPosition =
                    .dynamicTop
                recordLastPrompt()
            } else if notificationStatus == "Denied"
                && lastPromptedDate < twoMonthsAgo
            {
                print(
                    "Previously denied but last prompt was more than two months ago."
                )
                print(
                    "Bottom sheet position before: \(bottomSheetPosition)"
                )

                bottomSheetPosition = .dynamicTop

                print(
                    "Bottom sheet position after : \(bottomSheetPosition)"
                )
                recordLastPrompt()
            } else if notificationStatus == "Denied"
                && lastPromptedDate > twoMonthsAgo
            {
                print(
                    "Previously denied and prompted recently.")
                recordLastPrompt()

            }
        }  // notifications already approved

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
    func allowNotificationsTapped() {
        Task {
            let granted =
                await requestNotificationPermission()

            if granted {
                print("granted")
                bottomSheetPosition = .hidden
            } else {
                print("not granted")
                await withCheckedContinuation {
                    continuation in
                    showSettingsAlert {
                        // Once the user has interacted with the alert, continue and hide the bottom sheet
                        continuation.resume()
                        self.bottomSheetPosition =
                            .hidden
                    }
                }

            }

        }
    }
    //Maybe Later button
    func maybeLaterTapped() {

    }
}
