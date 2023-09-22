//
//  LanguageSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class LanguageSettingsFlow: Flow {
        
    private var chooseAppLanguageFlow: ChooseAppLanguageFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        sharedNavigationController.pushViewController(getLanguageSettingsView(), animated: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .backTappedFromLanguageSettings:
            flowDelegate?.navigate(step: .languageSettingsFlowCompleted(state: .userClosedLanguageSettings))
            
        case .chooseAppLanguageTappedFromLanguageSettings(let didChooseAppLanguageSubject):
            navigateToChooseAppLanguageFlow(didChooseAppLanguageSubject: didChooseAppLanguageSubject)
            
        case .chooseAppLanguageFlowCompleted(let state):
            navigateBackFromChooseAppLanguageFlow()
            
        default:
            break
        }
    }
    
    private func navigateToChooseAppLanguageFlow(didChooseAppLanguageSubject: PassthroughSubject<AppLanguageDomainModel, Never>) {
        
        guard chooseAppLanguageFlow == nil else {
            return
        }
        
        let chooseAppLanguageFlow = ChooseAppLanguageFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            didChooseAppLanguageSubject: didChooseAppLanguageSubject
        )
        
        self.chooseAppLanguageFlow = chooseAppLanguageFlow
    }
    
    private func navigateBackFromChooseAppLanguageFlow() {
        
        guard chooseAppLanguageFlow != nil else {
            return
        }
        
        navigationController.popViewController(animated: true)
        
        chooseAppLanguageFlow = nil
    }
}

extension LanguageSettingsFlow {
    
    func getLanguageSettingsView() -> UIViewController {
        
        let viewModel = LanguageSettingsViewModel(
            flowDelegate: self,
            getAppLanguageUseCase: appDiContainer.domainLayer.getAppLanguageUseCase(),
            getInterfaceStringUseCase: appDiContainer.domainLayer.getInterfaceStringUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        let view = LanguageSettingsView(viewModel: viewModel)
        
        let hostingView: UIHostingController<LanguageSettingsView> = UIHostingController(rootView: view)
        
        _ = hostingView.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        return hostingView
    }
}
