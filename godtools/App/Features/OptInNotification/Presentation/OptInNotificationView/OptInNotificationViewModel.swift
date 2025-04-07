//
//  OptInNotificationViewModel.swift
//  godtools
//
//  Created by Jason Bennett on 3/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import UIKit
import SwiftUI
import UserNotifications

class OptInNotificationViewModel: ObservableObject {

    private let optInNotificationRepository: OptInNotificationRepository
    private let viewOptInNotificationUseCase: ViewOptInNotificationUseCase
    private let viewOptInDialogUseCase: ViewOptInDialogUseCase
    private let requestNotificationPermissionUseCase:
        RequestNotificationPermissionUseCase
    private let checkNotificationStatusUseCase: CheckNotificationStatusUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let userDialogReponse: PassthroughSubject<Void, Never> =
        PassthroughSubject()

    private var isFirstDialogPrompt: Bool = false
    private var notificationStatus: String?
    private var notificationStatusCancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel =
        LanguageCodeDomainModel.english.rawValue

    @Published var isActive: Bool = false

    @Published var title: String = ""
    @Published var body: String = ""
    @Published var allowNotificationsActionTitle: String = ""
    @Published var maybeLaterActionTitle: String = ""

    init(
        optInNotificationRepository:
            OptInNotificationRepository,
        viewOptInNotificationUseCase: ViewOptInNotificationUseCase,
        viewOptInDialogUseCase: ViewOptInDialogUseCase,
        requestNotificationPermissionUseCase:
            RequestNotificationPermissionUseCase,
        checkNotificationStatusUseCase: CheckNotificationStatusUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        flowDelegate: FlowDelegate

    ) {

        self.optInNotificationRepository =
            optInNotificationRepository
        self.viewOptInNotificationUseCase = viewOptInNotificationUseCase
        self.viewOptInDialogUseCase = viewOptInDialogUseCase
        self.requestNotificationPermissionUseCase =
            requestNotificationPermissionUseCase
        self.checkNotificationStatusUseCase = checkNotificationStatusUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.flowDelegate = flowDelegate

        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .flatMap { appLanguage in
                viewOptInNotificationUseCase.viewPublisher(
                    appLanguage: appLanguage
                )
            }
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] (domainModel: ViewOptInNotificationDomainModel) in
                self?.title = domainModel.interfaceStrings.title
                self?.body = domainModel.interfaceStrings.body
                self?.allowNotificationsActionTitle =
                    domainModel.interfaceStrings.allowNotificationsActionTitle
                self?.maybeLaterActionTitle =
                    domainModel.interfaceStrings.maybeLaterActionTitle

            }
            .store(in: &cancellables)

        refreshNotificationStatus()

        NotificationCenter.default.publisher(
            for: UIApplication.didBecomeActiveNotification
        )
        .sink { [weak self] _ in
            self?.refreshNotificationStatus()
        }
        .store(in: &cancellables)

        userDialogReponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (void: Void) in

                self?.isActive = false
            }
            .store(in: &cancellables)

    }

    deinit {
        print("x deinit: \(type(of: self))")
    }

    func refreshNotificationStatus() {
        notificationStatusCancellable?.cancel()

        notificationStatusCancellable =
            checkNotificationStatusUseCase.getPermissionStatusPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.notificationStatus = status
                if status == "Undetermined" {
                    self?.isFirstDialogPrompt = true
                }
            }
    }

    func shouldPromptNotificationSheet() async {

        refreshNotificationStatus()
        print("Notification Status: \(notificationStatus ?? "nil")")

        let lastPrompted =
            optInNotificationRepository.getLastPrompted()
            ?? Date.distantPast

        let promptCount =
            optInNotificationRepository.getPromptCount()

        let currentDate = Date()
        let calendar = Calendar.current
        let twoMonthsAgo = calendar.date(
            byAdding: .month,
            value: -2,
            to: currentDate
        )!

        guard notificationStatus != "Approved" else { return }
        //        guard promptCount <= 5 else { return }

        if (notificationStatus == "Denied"
            || notificationStatus == "Undetermined")
            && lastPrompted > twoMonthsAgo
        {

            await MainActor.run {
                withAnimation {
                    isActive = true
                }
            }

            optInNotificationRepository.recordPrompt()
        }

    }
}

// MARK: - Inputs

extension OptInNotificationViewModel {

    func allowNotificationsTapped() {

        requestNotificationPermissionUseCase.getPermissionGrantedPublisher()
            .receive(
                on: DispatchQueue.main
            ).sink {
                [weak self]
                permissionGranted in
                guard let self = self else { return }

                if permissionGranted {
                    // Theoretically should never happen because a user who has granted permissions should not end up in this view
                    self.isActive = false
                } else {
                    if !isFirstDialogPrompt {
                        self.flowDelegate?.navigate(
                            step: .allowNotificationsTappedFromBottomSheet(
                                userDialogReponse: userDialogReponse
                            )
                        )
                    } else {
                        self.isActive = false
                    }

                }

            }.store(in: &cancellables)

    }

    func maybeLaterTapped() {
        withAnimation { isActive = false }

    }
}
