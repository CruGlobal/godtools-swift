//
//  LearnToShareToolFlow.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LearnToShareToolFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController(nibName: nil, bundle: nil)
        
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.setNavigationBarHidden(false, animated: false)
        
        let viewModel = LearnToShareToolViewModel(
            flowDelegate: self,
            learnToShareToolItemsProvider: appDiContainer.learnToShareToolItemsProvider,
            localizationServices: appDiContainer.localizationServices
        )
        let view = LearnToShareToolView(viewModel: viewModel)
        navigationController.setViewControllers([view], animated: false)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .closeTappedFromLearnToShareTool:
            flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool)
            
        default:
            break
        }
    }
}
