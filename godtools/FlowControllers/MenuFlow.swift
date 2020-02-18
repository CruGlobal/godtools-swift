//
//  MenuFlow.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MenuFlow: Flow {
    
    private(set) var menuView: MenuView!
    private var tutorialFlow: TutorialFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    var view: UIViewController {
        return menuView
    }
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        let viewModel = MenuViewModel(
            flowDelegate: self,
            loginClient: appDiContainer.loginClient,
            menuDataProvider: MenuDataProvider(),
            deviceLanguage: DeviceLanguagePreferences()
        )
        menuView = MenuView(viewModel: viewModel)
    }
}

extension MenuFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        switch step {
        case .tutorialTappedFromMenu:
            
            let tutorialFlow = TutorialFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: nil
            )
            navigationController.present(tutorialFlow.navigationController, animated: true, completion: nil)
            self.tutorialFlow = tutorialFlow
            
        case .dismissTutorial:
            navigationController.dismiss(animated: true, completion: nil)
            self.tutorialFlow = nil
            
        case .myAccountTappedFromMenu:
            print("Navigate to My Account")
            // TODO: Navigate to My Account will be implemented in GT-635.
            break
            
        default:
            break
        }
    }
}
