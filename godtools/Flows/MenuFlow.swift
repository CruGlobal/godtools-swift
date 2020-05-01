//
//  MenuFlow.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import MessageUI

class MenuFlow: Flow {
    
    private(set) var menuView: MenuView!
    private var tutorialFlow: TutorialFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    
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
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache,
            analytics: appDiContainer.analytics
        )
        menuView = MenuView(viewModel: viewModel)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .languageSettingsTappedFromMenu:
            
            let languageSettingsFlow = LanguageSettingsFlow(
                flowDelegate: self,
                appDiContainer: appDiContainer,
                sharedNavigationController: navigationController
            )
                        
            self.languageSettingsFlow = languageSettingsFlow
            
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
            
        case .doneTappedFromMenu:
            flowDelegate?.navigate(step: .doneTappedFromMenu)
                        
        case .myAccountTappedFromMenu:
            
            let viewModel = AccountViewModel(
                loginClient: appDiContainer.loginClient,
                globalActivityServices: appDiContainer.globalActivityServices
            )
            let view = AccountView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
            
        case .aboutTappedFromMenu:
            
            let viewModel = AboutViewModel(
                analytics: appDiContainer.analytics
            )
            let view = AboutView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
            
        case .helpTappedFromMenu:
                        
            navigateToWebContentView(webContent: HelpWebContent())
            
        case .contactUsTappedFromMenu:
           
            if MFMailComposeViewController.canSendMail() {
                
                let finishedSendingMail = CallbackHandler { [weak self] in
                    self?.navigationController.dismiss(animated: true, completion: nil)
                }
                
                let viewModel = MailViewModel(
                    flowDelegate: self,
                    toRecipients: ["support@godtoolsapp.com"],
                    subject: "Email to GodTools support",
                    message: "",
                    finishedSendingMailHandler: finishedSendingMail
                )
                
                let view = MailView(viewModel: viewModel)
                
                navigationController.present(view, animated: true, completion: nil)
            }
            else {
                navigateToWebContentView(webContent: ContactUsWebContent())
            }
            
        case .shareGodToolsTappedFromMenu:
            
            let textToShare: String = NSLocalizedString("share_god_tools_share_sheet_text", comment: "")
            let view = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            
            navigationController.present(view, animated: true, completion: nil)
            
        case .shareAStoryWithUsTappedFromMenu:
            
            if MFMailComposeViewController.canSendMail() {
                
                let finishedSendingMail = CallbackHandler { [weak self] in
                    self?.navigationController.dismiss(animated: true, completion: nil)
                }
                
                let viewModel = MailViewModel(
                    flowDelegate: self,
                    toRecipients: ["support@godtoolsapp.com"],
                    subject: "GodTools story",
                    message: "",
                    finishedSendingMailHandler: finishedSendingMail
                )
                
                let view = MailView(viewModel: viewModel)
                
                navigationController.present(view, animated: true, completion: nil)
            }
            else {
                navigateToWebContentView(webContent: ShareAStoryWithUsWebContent())
            }
            
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
