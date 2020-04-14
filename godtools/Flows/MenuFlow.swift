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
            deviceLanguage: appDiContainer.deviceLanguage,
            tutorialAvailability: appDiContainer.tutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache
        )
        menuView = MenuView(viewModel: viewModel)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .languageSettingsTappedFromMenu:
            break
            
        case .tutorialTappedFromMenu:
            
            let tutorialFlow = TutorialFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: nil
            )
            navigationController.present(tutorialFlow.navigationController, animated: true, completion: nil)
            self.tutorialFlow = tutorialFlow
            
        case .closeTappedFromTutorial:
            navigationController.dismiss(animated: true, completion: nil)
            self.tutorialFlow = nil
            
        case .startUsingGodToolsTappedFromTutorial:
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
                        
        case .myAccountTappedFromMenu:
            
            let viewModel = AccountViewModel(
                loginClient: appDiContainer.loginClient,
                globalActivityServices: appDiContainer.globalActivityServices
            )
            let view = AccountView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
            
        case .helpTappedFromMenu:
                        
            navigateToWebContentView(webContent: HelpWebContent())
            
        case .contactUsTappedFromMenu:
           
            navigateToWebContentView(webContent: ContactUsWebContent())
             
        case .shareAStoryWithUsTappedFromMenu:
            
            navigateToWebContentView(webContent: ShareAStoryWithUsWebContent())
            
        case .termsOfUseTappedFromMenu:
            
            navigateToWebContentView(webContent: TermsOfUseWebContent())
            
        case .privacyPolicyTappedFromMenu:
            
            navigateToWebContentView(webContent: PrivacyPolicyWebContent())
            
        case .copyrightInfoTappedFromMenu:
            
            navigateToWebContentView(webContent: CopyrightInfoWebContent())
            
        default:
            break
        }
    }
    
    private func navigateToWebContentView(webContent: WebContentType) {
        
        let viewModel = WebContentViewModel(
            analytics: appDiContainer.analytics,
            webContent: webContent
        )
        let view = WebContentView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
    }
}
