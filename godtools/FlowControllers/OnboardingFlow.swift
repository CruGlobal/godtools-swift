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
        
        let viewModel = OnboardingWelcomeViewModel(
            flowDelegate: self,
            analytics: appDiContainer.analytics,
            appsFlyer: appDiContainer.appsFlyer
        )
        let view = OnboardingWelcomeView(viewModel: viewModel)
        navigationController.setViewControllers([view], animated: false)
    }
}

extension OnboardingFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .beginTappedFromOnboardingWelcome:
           
            let viewModel = OnboardingTutorialViewModel(
                flowDelegate: self,
                analytics: appDiContainer.analytics,
                appsFlyer: appDiContainer.appsFlyer,
                onboardingTutorialProvider: OnboardingTutorialProvider(),
                onboardingTutorialAvailability: appDiContainer.onboardingTutorialAvailability,
                openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache
            )
            let view = OnboardingTutorialView(viewModel: viewModel)
            navigationController.setViewControllers([view], animated: true)
            
        case .skipTappedFromOnboardingTutorial:
            flowDelegate?.navigate(step: .dismissOnboardingTutorial)
            
        case .showMoreTappedFromOnboardingTutorial:
            flowDelegate?.navigate(step: step)
            
        case .getStartedTappedFromOnboardingTutorial:
            flowDelegate?.navigate(step: .dismissOnboardingTutorial)
        
        default:
            break
        }
    }
}
