//
//  OptInNotificationViewModel.swift
//  godtools
//
//  Created by Jason Bennett on 3/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import UIKit
import UserNotifications

class OptInNotificationViewModel: ObservableObject {

    private let optInNotificationRepository: OptInNotificationRepository
    private let launchCountRepository: LaunchCountRepository
    private let viewOptInNotificationUseCase: ViewOptInNotificationUseCase
    private let viewOptInDialogUseCase: ViewOptInDialogUseCase
    private let requestNotificationPermissionUseCase:
        RequestNotificationPermissionUseCase
    private let checkNotificationStatusUseCase: CheckNotificationStatusUseCase

    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let userDialogReponse: PassthroughSubject<Void, Never> =
        PassthroughSubject()

    private var isOnboardingLaunch: Bool = false
    private var isFirstDialogPrompt: Bool = false
    private var notificationStatus: PermissionStatusDomainModel?
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
        launchCountRepository: LaunchCountRepository,
        viewOptInNotificationUseCase: ViewOptInNotificationUseCase,
        viewOptInDialogUseCase: ViewOptInDialogUseCase,
        requestNotificationPermissionUseCase:
            RequestNotificationPermissionUseCase,
        checkNotificationStatusUseCase: CheckNotificationStatusUseCase,

        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        flowDelegate: FlowDelegate

    ) {

        self.optInNotificationRepository = optInNotificationRepository
        self.launchCountRepository = launchCountRepository
        self.viewOptInNotificationUseCase = viewOptInNotificationUseCase
        self.viewOptInDialogUseCase = viewOptInDialogUseCase
        self.requestNotificationPermissionUseCase = requestNotificationPermissionUseCase
        self.checkNotificationStatusUseCase = checkNotificationStatusUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.flowDelegate = flowDelegate

        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .flatMap { appLanguage in
                viewOptInNotificationUseCase.viewPublisher(
                    appLanguage: appLanguage
                )
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewOptInNotificationDomainModel) in
               
                self?.title = domainModel.interfaceStrings.title
                self?.body = domainModel.interfaceStrings.body
                self?.allowNotificationsActionTitle =
                    domainModel.interfaceStrings.allowNotificationsActionTitle
                self?.maybeLaterActionTitle =
                    domainModel.interfaceStrings.maybeLaterActionTitle

            }
            .store(in: &cancellables)

        launchCountRepository.getLaunchCountPublisher().sink { [weak self] count in
            
            self?.isOnboardingLaunch = count == 1

        }.store(in: &cancellables)

        refreshNotificationStatus()

        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
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
            .sink { [weak self] (status: PermissionStatusDomainModel) in
                
                self?.notificationStatus = status
                
                if status == .undetermined {
                    self?.isFirstDialogPrompt = true
                }
            }
    }

    func shouldPromptNotificationSheet() async {

        refreshNotificationStatus()

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

        guard isOnboardingLaunch == false else { return }
        guard notificationStatus != .approved else { return }
        guard promptCount <= 5 else { return }

        if (notificationStatus == .denied || notificationStatus == .undetermined)
            && lastPrompted < twoMonthsAgo {

            await MainActor.run {
                isActive = true
            }

            optInNotificationRepository.recordPrompt()
        }
    }
}

// MARK: - Inputs

extension OptInNotificationViewModel {

    func allowNotificationsTapped() {

        requestNotificationPermissionUseCase.getPermissionGrantedPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (permissionGranted: Bool) in
                
                guard let self = self else {
                    return
                }

                if permissionGranted {
                    // Theoretically should never happen because a user who has granted permissions shouldn't end up in this view

                    self.isActive = false

                } else if !isFirstDialogPrompt {

                    self.flowDelegate?.navigate(
                        step: .allowNotificationsTappedFromBottomSheet(
                            userDialogReponse: userDialogReponse
                        )
                    )
                }
                else {

                    self.isActive = false
                }

            }.store(in: &cancellables)
    }

    func maybeLaterTapped() {
        isActive = false
    }
}
