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

final class OptInNotificationFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case completed
    }
                
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    init(appDiContainer: AppDiContainer, notificationPromptType: OptInNotificationViewModel.NotificationPromptType) {
        
        let stepEmitter = FlowStepEmitter()
        
        let viewModel = OptInNotificationViewModel(
            stepEmitter: stepEmitter,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getOptInNotificationStringsUseCase: appDiContainer.feature.optInNotification.domainLayer.getOptInNotificationStringsUseCase(),
            notificationPromptType: notificationPromptType
        )
        
        let view = OptInNotificationView(viewModel: viewModel)
        
        let hostingView = AppHostingController<OptInNotificationView>(
            rootView: view,
            navigationBar: nil,
            animateInAnimatedTransitioning: NoAnimationTransition(transition: .transitionIn),
            animateOutAnimatedTransitioning: NoAnimationTransition(transition: .transitionOut)
        )
        
        hostingView.view.backgroundColor = .clear
        hostingView.modalPresentationStyle = .overCurrentContext
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: hostingView,
            stepEmitter: stepEmitter,
            navigationController: AppNavigationController(
                navigationBarAppearance: nil,
                hidesNavigationBar: true
            ),
            onPresentType: .presentInitialView
        )
  
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .assign(to: &$appLanguage)
        
        appDiContainer.feature.optInNotification.dataLayer
            .getOptInNotificationRepository()
            .recordPrompt()
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
            
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
    
    private func completeFlow(state: OptInNotificationFlow.CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.optInNotificationFlowCompleted(state: state))
    }
}

extension OptInNotificationFlow {
    
    private func presentRequestNotificationPermission() {
        
        Task {
            
            let granted: Bool = try await appDiContainer.feature.optInNotification.domainLayer
                .getRequestNotificationPermissionUseCase()
                .execute()
                        
            navigate(
                step: granted ? AppFlowStep.allowTappedFromRequestNotificationPermission : AppFlowStep.dontAllowTappedFromRequestNotificationPermission
            )
        }
    }
}
