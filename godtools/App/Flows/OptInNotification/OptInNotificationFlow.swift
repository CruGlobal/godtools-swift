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
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var checkNotificationStatusCancellable: AnyCancellable?
    
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
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        presentOnNavigationController.present(getOptInNotificationView(), animated: true)
        
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
                            
            checkNotificationStatusCancellable = appDiContainer.feature.optInNotification.domainLayer
                .getCheckNotificationStatusUseCase()
                .getPermissionStatusPublisher()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] (status: PermissionStatusDomainModel) in
                    
                    self?.checkNotificationStatusCancellable = nil
                    
                    self?.navigationController.dismissPresented(animated: true, completion: {
                        
                        switch status {
                            
                        case .undetermined:
                            self?.presentRequestNotificationPermission()
                        
                        case .approved:
                            self?.completeFlow(state: .completed)
                        
                        case .denied:
                            self?.presentOptInNotificationDialogView(animated: true)
                        
                        case .unknown:
                            self?.presentOptInNotificationDialogView(animated: true)
                        }
                    })
                })
            
        case .maybeLaterTappedFromOptInNotification:
            completeFlow(state: .completed)
            
        case .cancelTappedFromOptInNotificationDialog:
            completeFlow(state: .completed)
            
        case .settingsTappedFromOptInNotificationDialog:
            
            completeFlow(state: .completed)
            
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            
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
    
    private func getOptInNotificationView() -> UIViewController {
        
        let viewModel = OptInNotificationViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewOptInNotificationUseCase: appDiContainer.feature.optInNotification.domainLayer.getViewOptInNotificationUseCase()
        )
        
        let view = OptInNotificationView(viewModel: viewModel)
        
        let transparentModalBottomView = TransparentModalBottomView<OptInNotificationView>(view: view, navigationBar: nil)
        
        let transparentModal = TransparentModalView(
            flowDelegate: self,
            modalView: transparentModalBottomView,
            closeModalFlowStep: .closeTappedFromOptInNotification
        )
        
        return transparentModal
    }
    
    private func presentRequestNotificationPermission() {
        
        appDiContainer.feature.optInNotification.domainLayer
            .getRequestNotificationPermissionUseCase()
            .requestNotificationPermissionPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (granted: Bool) in
                
                if granted {
                    self?.navigate(step: .allowTappedFromRequestNotificationPermission)
                }
                else {
                    self?.navigate(step: .dontAllowTappedFromRequestNotificationPermission)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Notification Dialog

extension OptInNotificationFlow {
    
    private func presentOptInNotificationDialogView(animated: Bool) {
        
        appDiContainer.feature.optInNotification.domainLayer
            .getViewOptInDialogUseCase()
            .viewPublisher(appLanguage: appLanguage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewOptInDialogDomainModel) in
                
                self?.presentOptInNotificationDialogView(domainModel: domainModel, animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func presentOptInNotificationDialogView(domainModel: ViewOptInDialogDomainModel, animated: Bool) {
        
        let view = getOptInNotificationDialogView(domainModel: domainModel)

        navigationController.present(view, animated: animated)
    }
    
    private func getOptInNotificationDialogView(domainModel: ViewOptInDialogDomainModel) -> UIViewController {
        
        let viewModel = OptInNotificationDialogViewModel(
            flowDelegate: self,
            viewOptInDialogDomainModel: domainModel
        )
        
        let view = OptInNotificationDialogView(viewModel: viewModel)
        
        return view.controller
    }
}
