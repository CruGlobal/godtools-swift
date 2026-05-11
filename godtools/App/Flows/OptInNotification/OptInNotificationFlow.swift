//
//  OptInNotificationFlow.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

class OptInNotificationFlow: Flow {
        
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, presentOnNavigationController: AppNavigationController) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = presentOnNavigationController
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .assign(to: &$appLanguage)
        
        Task {
            
            let status: PermissionStatusDomainModel = try await appDiContainer.feature
                .optInNotification
                .domainLayer
                .getCheckNotificationStatusUseCase()
                .execute()
            
            let notificationPromptType: OptInNotificationViewModel.NotificationPromptType
            
            switch status {
            case .undetermined:
                notificationPromptType = .allow
            default:
                notificationPromptType = .settings
            }
                            
            let optInNotificationView: UIViewController = getOptInNotificationView(
                notificationPromptType: notificationPromptType
            )
            
            presentOnNavigationController.present(
                optInNotificationView,
                animated: true
            )
        }
        
        appDiContainer.feature.optInNotification.dataLayer.getOptInNotificationRepository().recordPrompt()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        case .closeTappedFromOptInNotification:
            completeFlow(state: .completed)
            
        case .allowNotificationsTappedFromOptInNotification:
            presentRequestNotificationPermission()
            
        case .settingsTappedFromOptInNotification:
            
            completeFlow(state: .completed)
            
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            
        case .maybeLaterTappedFromOptInNotification:
            completeFlow(state: .completed)
            
        case .dontAllowTappedFromRequestNotificationPermission:
            completeFlow(state: .completed)
            
        case .allowTappedFromRequestNotificationPermission:
            completeFlow(state: .completed)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: OptInNotificationFlowCompletedState) {
        flowDelegate?.navigate(step: .optInNotificationFlowCompleted(state: .completed))
    }
}

extension OptInNotificationFlow {
    
    private func getOptInNotificationView(notificationPromptType: OptInNotificationViewModel.NotificationPromptType) -> UIViewController {
        
        let viewModel = OptInNotificationViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getOptInNotificationStringsUseCase: appDiContainer.feature.optInNotification.domainLayer.getOptInNotificationStringsUseCase(),
            notificationPromptType: notificationPromptType
        )
        
        let view = OptInNotificationView(viewModel: viewModel, overlayTappedClosure: { [weak self] in
            
            self?.navigate(step: .closeTappedFromOptInNotification)
        })
        
        let hostingView = AppHostingController<OptInNotificationView>(
            rootView: view,
            navigationBar: nil,
            animateInAnimatedTransitioning: NoAnimationTransition(transition: .transitionIn),
            animateOutAnimatedTransitioning: NoAnimationTransition(transition: .transitionOut)
        )

        hostingView.view.backgroundColor = .clear
        hostingView.modalPresentationStyle = .overCurrentContext
        
        return hostingView
    }
    
    private func presentRequestNotificationPermission() {
        
        Task {
            
            let granted: Bool = try await appDiContainer.feature.optInNotification.domainLayer
                .getRequestNotificationPermissionUseCase()
                .execute()
                        
            navigate(
                step: granted ? .allowTappedFromRequestNotificationPermission : .dontAllowTappedFromRequestNotificationPermission
            )
        }
    }
}
