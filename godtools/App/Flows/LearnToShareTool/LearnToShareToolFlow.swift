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
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, resource: ResourceModel) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController(nibName: nil, bundle: nil)
        
        navigationController.modalPresentationStyle = .fullScreen
        
        navigationController.setNavigationBarHidden(false, animated: false)
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: .clear,
            controlColor: ColorPalette.gtBlue.uiColor,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: true
        )
                
        let viewModel = LearnToShareToolViewModel(
            flowDelegate: self,
            resource: resource,
            getLearnToShareToolItemsUseCase: appDiContainer.domainLayer.getLearnToShareToolItemsUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices()
        )
        let view = LearnToShareToolView(viewModel: viewModel)
        navigationController.setViewControllers([view], animated: false)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .continueTappedFromLearnToShareTool(let resource):
            flowDelegate?.navigate(step: .continueTappedFromLearnToShareTool(resource: resource))
            
        case .closeTappedFromLearnToShareTool(let resource):
            flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool(resource: resource))
            
        default:
            break
        }
    }
}
