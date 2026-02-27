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
    
    private let viewOptInNotificationUseCase: ViewOptInNotificationUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let notificationPromptType: NotificationPromptType
    
    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var title: String = ""
    @Published private(set) var body: String = ""
    @Published private(set) var notificationsActionTitle: String = ""
    @Published private(set) var maybeLaterActionTitle: String = ""

    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewOptInNotificationUseCase: ViewOptInNotificationUseCase, notificationPromptType: NotificationPromptType) {

        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewOptInNotificationUseCase = viewOptInNotificationUseCase
        self.notificationPromptType = notificationPromptType

        getCurrentAppLanguageUseCase
            .execute()
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .map { appLanguage in
                viewOptInNotificationUseCase.viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewOptInNotificationDomainModel) in
                     
                let actionTitle: String
                
                switch notificationPromptType {
                case .allow:
                    actionTitle = domainModel.interfaceStrings.allowNotificationsActionTitle
                case .settings:
                    actionTitle = domainModel.interfaceStrings.notificationSettingsActionTitle
                }
                
                self?.notificationsActionTitle = actionTitle
                
                self?.title = domainModel.interfaceStrings.title
                self?.body = domainModel.interfaceStrings.body
                self?.maybeLaterActionTitle = domainModel.interfaceStrings.maybeLaterActionTitle
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
