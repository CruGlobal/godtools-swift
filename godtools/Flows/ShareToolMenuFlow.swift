//
//  ShareToolMenuFlow.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolMenuFlow: Flow {

    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(appDiContainer: AppDiContainer, navigationController: UINavigationController, resource: ResourceModel, language: LanguageModel, pageNumber: Int) {
        
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
            break
            
        default:
            break
        }
    }
}
