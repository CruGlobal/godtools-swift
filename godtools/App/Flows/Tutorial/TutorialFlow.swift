//
//  TutorialFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialFlow: Flow {
    
    private let flowDiContainer: TutorialFlowDiContainer
    
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
        self.flowDiContainer = TutorialFlowDiContainer(appDiContainer: appDiContainer)
        self.navigationController = sharedNavigationController ?? UINavigationController(nibName: nil, bundle: nil)
             
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: .white,
            controlColor: nil,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: false
        )
        
        let viewModel = TutorialViewModel(
            flowDelegate: self,
            getTutorialUseCase: flowDiContainer.getTutorialUseCase(),
            analytics: appDiContainer.analytics,
            tutorialVideoAnalytics: appDiContainer.getTutorialVideoAnalytics()
        )
        let view = TutorialView(viewModel: viewModel)
        
        let animated: Bool = sharedNavigationController != nil
        navigationController.setViewControllers([view], animated: animated)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
           
        case .closeTappedFromTutorial:
            flowDelegate?.navigate(step: .closeTappedFromTutorial)
            
        case .startUsingGodToolsTappedFromTutorial:
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
            
        default:
            break
        }
    }
}
