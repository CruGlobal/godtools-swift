//
//  OnboardingFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingFlow: NSObject, Flow {
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    required init(appDiContainer: AppDiContainer) {
        print("init: \(type(of: self))")
        
        self.appDiContainer = appDiContainer
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

extension OnboardingFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .beginTappedFromOnboardingWelcome:
           
            let viewModel = OnboardingTutorialViewModel(
                flowDelegate: self,
                onboardingTutorialProvider: OnboardingTutorialProvider()
            )
            let view = OnboardingTutorialView(viewModel: viewModel)
            navigationController.setViewControllers([view], animated: true)
            
        case .skipTappedFromOnboardingTutorial:
            print("skip tapped")
            break
            
        case .showMoreTappedFromOnboardingTutorial:
            print("show more tapped")
            break
            
        case .getStartedTappedFromOnboardingTutorial:
            print("get started tapped")
            break
            
        default:
            break
        }
    }
}
