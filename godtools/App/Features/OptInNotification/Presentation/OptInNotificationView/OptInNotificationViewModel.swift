//
//  OptInNotificationViewModel.swift
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

class OptInNotificationViewModel: ObservableObject {

    private let lastPromptedOptInNotificationRepository:
        LastPromptedOptInNotificationRepository
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

    @Published var bottomSheetPosition: BottomSheetPosition = .hidden

    @Published var title: String = ""
    @Published var body: String = ""
    @Published var allowNotificationsActionTitle: String = ""
    @Published var maybeLaterActionTitle: String = ""

    init(
        lastPromptedOptInNotificationRepository:
            LastPromptedOptInNotificationRepository,
        viewOptInNotificationUseCase: ViewOptInNotificationUseCase,
        viewOptInDialogUseCase: ViewOptInDialogUseCase,
        requestNotificationPermissionUseCase:
            RequestNotificationPermissionUseCase,
        checkNotificationStatusUseCase: CheckNotificationStatusUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        flowDelegate: FlowDelegate

    ) {

        self.lastPromptedOptInNotificationRepository =
            lastPromptedOptInNotificationRepository
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
                    appLanguage: appLanguage)
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

                self?.bottomSheetPosition = .hidden
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

        let lastPrompted =
            lastPromptedOptInNotificationRepository.getLastPrompted()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let lastPromptedDate = lastPrompted.flatMap { dateFormatter.date(from: $0) } ?? Date()


        let currentDate = Date()
        let calendar = Calendar.current
        let twoMonthsAgo = calendar.date(
            byAdding: .month, value: -2, to: currentDate)!

        if notificationStatus != "Approved" {
            if notificationStatus == "Undetermined"
                || notificationStatus == "Denied"
                    && lastPromptedDate < twoMonthsAgo
            {
                await MainActor.run {
                    bottomSheetPosition = .dynamicTop
                }

                // First time prompt, or previously denied but due for another prompt
                lastPromptedOptInNotificationRepository.recordLastPrompted(
                    dateString: dateFormatter.string(from: Date.now))

            }
            // Permission already granted, or previously denied and prompted recently (No-Op)
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
                    self.bottomSheetPosition = .hidden
                } else {
                    if !isFirstDialogPrompt {
                        self.flowDelegate?.navigate(
                            step: .allowNotificationsTappedFromBottomSheet(
                                userDialogReponse: userDialogReponse))
                    } else {
                        self.bottomSheetPosition = .hidden
                    }

                }

            }.store(in: &cancellables)

    }

    func maybeLaterTapped() {
        bottomSheetPosition = .hidden
    }
}
