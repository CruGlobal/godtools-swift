//
//  ShareToolMenuFlow.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolMenuFlow: Flow {

    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, navigationController: UINavigationController, resource: ResourceModel, language: LanguageModel, pageNumber: Int) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = navigationController
        
        let viewModel = ShareToolMenuViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices,
            resource: resource,
            language: language,
            pageNumber: pageNumber
        )
        let view = ShareToolMenuView(viewModel: viewModel)
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .shareToolTappedFromShareToolMenu(let resource, let language, let pageNumber):
            
            let viewModel = ShareToolViewModel(
                resource: resource,
                language: language,
                pageNumber: pageNumber,
                localizationServices: appDiContainer.localizationServices,
                analytics: appDiContainer.analytics
            )
            
            let view = ShareToolView(viewModel: viewModel)
            
            navigationController.present(
                view.controller,
                animated: true,
                completion: nil
            )
            
        case .remoteShareToolTappedFromShareToolMenu:
            
            let tutorialItemsProvider = ShareToolScreenTutorialItemProvider(localizationServices: appDiContainer.localizationServices)
                        
            let viewModel = ShareToolScreenTutorialViewModel(
                flowDelegate: self,
                localizationServices: appDiContainer.localizationServices,
                tutorialItemsProvider: tutorialItemsProvider
            )

            let view = ShareToolScreenTutorialView(viewModel: viewModel)
            let modal = ModalNavigationController(rootView: view)

            navigationController.present(
                modal,
                animated: true,
                completion: nil
            )
            
        case .closeTappedFromShareToolScreenTutorial:
            navigationController.dismiss(animated: true, completion: nil)
            flowDelegate?.navigate(step: .closeTappedFromShareToolScreenTutorial)
            
        default:
            break
        }
    }
}
