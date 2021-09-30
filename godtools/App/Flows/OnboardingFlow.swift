//
//  OnboardingFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController(nibName: nil, bundle: nil)
                
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.setNavigationBarHidden(false, animated: false)
        
        let onboardingTutorialProvider = OnboardingTutorialProvider(localizationServices: appDiContainer.localizationServices)
        
        let viewModel = TutorialPagerViewModel(
            flowDelegate: flowDelegate,
            analyticsContainer: appDiContainer.analytics,
            tutorialPagerProvider: onboardingTutorialProvider,
            onboardingTutorialAvailability: appDiContainer.onboardingTutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache,
            customViewBuilder: <#T##CustomViewBuilderType#>,
            analyticsScreenName: "onboarding",
            skipButtonTitle: "Skip"
        )
        let view = TutorialPagerView(viewModel: viewModel)
        
        navigationController.setViewControllers([view], animated: false)
    }
}

extension OnboardingFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .skipTappedFromOnboardingTutorial:
            flowDelegate?.navigate(step: .dismissOnboardingTutorial)
            
        case .endTutorialFromOnboardingTutorial:
            flowDelegate?.navigate(step: .dismissOnboardingTutorial)
        
        default:
            break
        }
    }
}
