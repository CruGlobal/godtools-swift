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

    private let viewOptInNotificationUseCase: ViewOptInNotificationUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase

    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    @Published private(set) var isInitialPrompt: Bool = false
    @Published private(set) var title: String = ""
    @Published private(set) var body: String = ""
    @Published private(set) var allowNotificationsActionTitle: String = ""
    @Published private(set) var notificationSettingsActionTitle: String = ""
    @Published private(set) var maybeLaterActionTitle: String = ""

    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewOptInNotificationUseCase: ViewOptInNotificationUseCase) {

        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewOptInNotificationUseCase = viewOptInNotificationUseCase

        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .map { appLanguage in
                viewOptInNotificationUseCase.viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewOptInNotificationDomainModel) in
                
                self?.isInitialPrompt = domainModel.isInitialPrompt
                
                self?.title = domainModel.interfaceStrings.title
                self?.body = domainModel.interfaceStrings.body
                self?.allowNotificationsActionTitle =
                    domainModel.interfaceStrings.allowNotificationsActionTitle
                self?.notificationSettingsActionTitle =
                domainModel.interfaceStrings.notificationSettingsActionTitle
                self?.maybeLaterActionTitle =
                    domainModel.interfaceStrings.maybeLaterActionTitle
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
        
        if isInitialPrompt {
            flowDelegate?.navigate(step: .allowNotificationsTappedFromOptInNotification)
        } else {
            flowDelegate?.navigate(step: .settingsTappedFromOptInNotification)
        }
        
    }

    func maybeLaterTapped() {
        
        flowDelegate?.navigate(step: .maybeLaterTappedFromOptInNotification)
    }
}
