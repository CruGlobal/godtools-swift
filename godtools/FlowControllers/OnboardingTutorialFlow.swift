//
//  OnboardingTutorialFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

enum OnboardingTutorialFlowStep: FlowStep {
    case beginTappedFromOnboardingWelcome
}

class OnboardingTutorialFlow: NSObject {
    
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))\n")
    }
    
    override init() {
        print("init: \(type(of: self))\n")
        
        self.navigationController = UINavigationController(nibName: nil, bundle: nil)
        
        super.init()
        
        navigationController.navigationBar.barTintColor = UIColor.white
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.setNavigationBarHidden(false, animated: false)
        
        let viewModel = OnboardingWelcomeViewModel(flowDelegate: self)
        let view = OnboardingWelcomeView(viewModel: viewModel)
        navigationController.setViewControllers([view], animated: false)
    }
}

extension OnboardingTutorialFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        guard let onboardingTutorialFlowStep = step as? OnboardingTutorialFlowStep else {
            return
        }
        
        switch onboardingTutorialFlowStep {
            
        case .beginTappedFromOnboardingWelcome:
           
            let viewModel = OnboardingTutorialViewModel(
                flowDelegate: self,
                onboardingTutorialProvider: OnboardingTutorialProvider()
            )
            let view = OnboardingTutorialView(viewModel: viewModel)
            navigationController.setViewControllers([view], animated: true)
        }
    }
}
