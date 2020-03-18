//
//  TutorialFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialFlow: Flow {
    
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
        navigationController.navigationBar.barTintColor = UIColor.white
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.setNavigationBarHidden(false, animated: false)
        
        let viewModel = TutorialViewModel(
            flowDelegate: self,
            analytics: appDiContainer.analytics,
            appsFlyer: appDiContainer.appsFlyer,
            tutorialItemsProvider: TutorialItemProvider(),
            deviceLanguage: appDiContainer.deviceLanguage
        )
        let view = TutorialView(viewModel: viewModel)
        
        let animated: Bool = sharedNavigationController != nil
        navigationController.setViewControllers([view], animated: animated)
    }
}

extension TutorialFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        switch step {
           
        case .closeTappedFromTutorial:
            flowDelegate?.navigate(step: .dismissTutorial)
            
        case .startUsingGodToolsTappedFromTutorial:
            flowDelegate?.navigate(step: .dismissTutorial)
            
        default:
            break
        }
    }
}
