//
//  ToolsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolsFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
             
        let openTutorialViewModel = OpenTutorialViewModel(
            flowDelegate: self,
            tutorialAvailability: appDiContainer.tutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache,
            analytics: appDiContainer.analytics
        )
        
        let myToolsViewModel = MyToolsViewModel(
            flowDelegate: self,
            analytics: appDiContainer.analytics
        )
        
        let allToolsViewModel = AllToolsViewModel(
            realm: appDiContainer.realmDatabase.mainThreadRealm
        )
        
        let viewModel = ToolsViewModel(
            flowDelegate: self
        )
        let view = ToolsView(
            viewModel: viewModel,
            openTutorialViewModel: openTutorialViewModel,
            myToolsViewModel: myToolsViewModel,
            allToolsViewModel: allToolsViewModel
        )
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
           
        case .menuTappedFromTools:
            flowDelegate?.navigate(step: .showMenu)
        
        case .languageSettingsTappedFromTools:
            flowDelegate?.navigate(step: .showLanguageSettings)
            
        case .openTutorialTapped:
            flowDelegate?.navigate(step: .openTutorialTapped)
            
        default:
            break
        }
    }
}
