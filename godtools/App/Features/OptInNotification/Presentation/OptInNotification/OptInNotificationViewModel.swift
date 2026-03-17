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

@MainActor class OptInNotificationViewModel: ObservableObject {
    
    enum NotificationPromptType {
        case allow
        case settings
    }
    
    private let getOptInNotificationStringsUseCase: GetOptInNotificationStringsUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let notificationPromptType: NotificationPromptType
    
    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var strings = OptInNotificationStringsDomainModel.emptyValue
    @Published private(set) var notificationsActionTitle: String = ""

    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getOptInNotificationStringsUseCase: GetOptInNotificationStringsUseCase, notificationPromptType: NotificationPromptType) {

        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getOptInNotificationStringsUseCase = getOptInNotificationStringsUseCase
        self.notificationPromptType = notificationPromptType

        getCurrentAppLanguageUseCase
            .execute()
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .map { appLanguage in
                getOptInNotificationStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: OptInNotificationStringsDomainModel) in
                     
                self?.strings = strings
                
                let actionTitle: String
                
                switch notificationPromptType {
                case .allow:
                    actionTitle = strings.allowNotificationsActionTitle
                case .settings:
                    actionTitle = strings.notificationSettingsActionTitle
                }
                
                self?.notificationsActionTitle = actionTitle
            }
            .store(in: &cancellables)
    }

    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension OptInNotificationViewModel {

    func allowNotificationsTapped() {
        
        switch notificationPromptType {
        case .allow:
            flowDelegate?.navigate(step: .allowNotificationsTappedFromOptInNotification)
        case .settings:
            flowDelegate?.navigate(step: .settingsTappedFromOptInNotification)
        }
    }

    func maybeLaterTapped() {
        
        flowDelegate?.navigate(step: .maybeLaterTappedFromOptInNotification)
    }
}
