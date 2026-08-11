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

@MainActor
final class OptInNotificationViewModel: ObservableObject {
    
    enum NotificationPromptType {
        case allow
        case settings
    }
    
    private let stepEmitter: FlowStepEmitter
    private let getOptInNotificationStringsUseCase: GetOptInNotificationStringsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let notificationPromptType: NotificationPromptType
    
    private var cancellables: Set<AnyCancellable> = Set()

    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var strings = OptInNotificationStringsDomainModel.emptyValue
    @Published private(set) var notificationsActionTitle: String = ""

    init(
        stepEmitter: FlowStepEmitter,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getOptInNotificationStringsUseCase: GetOptInNotificationStringsUseCase,
        notificationPromptType: NotificationPromptType
    ) {

        self.stepEmitter = stepEmitter
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getOptInNotificationStringsUseCase = getOptInNotificationStringsUseCase
        self.notificationPromptType = notificationPromptType

        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            }
            .store(in: &cancellables)
    }

    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        Task {

            let strings = await getOptInNotificationStringsUseCase
                .execute(appLanguage: appLanguage)

            let actionTitle: String

            switch notificationPromptType {
            case .allow:
                actionTitle = strings.allowNotificationsActionTitle
            case .settings:
                actionTitle = strings.notificationSettingsActionTitle
            }

            self.strings = strings

            notificationsActionTitle = actionTitle
        }
    }
}

// MARK: - Inputs

extension OptInNotificationViewModel {

    func overlayTapped() {
        
        stepEmitter.emit(step: AppFlowStep.closeTappedFromOptInNotification)
    }
    
    func allowNotificationsTapped() {
        
        switch notificationPromptType {
        case .allow:
            stepEmitter.emit(step: AppFlowStep.allowNotificationsTappedFromOptInNotification)
        case .settings:
            stepEmitter.emit(step: AppFlowStep.settingsTappedFromOptInNotification)
        }
    }

    func maybeLaterTapped() {
        
        stepEmitter.emit(step: AppFlowStep.maybeLaterTappedFromOptInNotification)
    }
}
