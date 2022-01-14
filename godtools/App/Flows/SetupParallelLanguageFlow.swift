//
//  SetupParallelLanguageFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class SetupParallelLanguageFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
        
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController?) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController ?? UINavigationController(nibName: nil, bundle: nil)

        navigationController.modalPresentationStyle = .fullScreen
        
        navigationController.setNavigationBarHidden(false, animated: false)
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: .clear,
            controlColor: nil,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: true
        )
        
        presentSetupParallelLangaugeModal()
    }
    
    private func dismissModal() {
        
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    private func presentSetupParallelLangaugeModal() {
        
        let viewModel = SetupParallelLanguageViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices,
            languageSettingsService: appDiContainer.languageSettingsService,
            setupParallelLanguageAvailability: appDiContainer.getSetupParallelLanguageAvailability()
        )
        let view = SetupParallelLanguageView(viewModel: viewModel)
        
        navigationController.setViewControllers([view], animated: false)
    }
}

extension SetupParallelLanguageFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        /*case .selectLanguageTappedFromSetupParallelLanguage:
            presentParallelLanguageModal()
        
        case .closeTappedFromSetupParallelLanguage:
            completeOnboardingFlow(onboardingFlowCompletedState: nil)

        case .yesTappedFromSetupParallelLanguage:
            presentParallelLanguageModal()

        case .noThanksTappedFromSetupParallelLanguage:
            completeOnboardingFlow(onboardingFlowCompletedState: nil)

        case .backgroundTappedFromParallelLanguageModal:
            dismissModal()
        
        case .selectTappedFromParallelLanguageModal:
            dismissModal()
        
        case .getStartedTappedFromSetupParallelLanguage:
            completeOnboardingFlow(onboardingFlowCompletedState: nil)*/

        default:
            break
        }
    }
}
