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
    
    private var tutorialFlow: TutorialFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        
        navigationController = UINavigationController()
        navigationController.navigationBar.barTintColor = UIColor.gtBlue
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gtWhite,
            NSAttributedString.Key.font: UIFont.gtSemiBold(size: 17.0)
        ]
        
        let viewModel = MenuViewModel(
            flowDelegate: self,
            config: appDiContainer.config,
            loginClient: appDiContainer.loginClient,
            menuDataProvider: MenuDataProvider(localizationServices: appDiContainer.localizationServices),
            deviceLanguage: appDiContainer.deviceLanguage,
            tutorialAvailability: appDiContainer.tutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache,
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics
        )
        let view = MenuView(viewModel: viewModel)
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    var view: UIView {
        return navigationController.view
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
            print(" menu flow done tapped")
            flowDelegate?.navigate(step: .doneTappedFromMenu)
                        
        case .myAccountTappedFromMenu:
            
            let viewModel = AccountViewModel(
                loginClient: appDiContainer.loginClient,
                globalActivityServices: appDiContainer.globalActivityServices,
                localizationServices: appDiContainer.localizationServices,
                analytics: appDiContainer.analytics
            )
            let view = AccountView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
            
        case .aboutTappedFromMenu:
            
            let aboutTextProvider = LocalizedAboutTextProvider(
                localizationServices: appDiContainer.localizationServices
            )
            
            let viewModel = AboutViewModel(
                aboutTextProvider: aboutTextProvider,
                localizationServices: appDiContainer.localizationServices,
                analytics: appDiContainer.analytics
            )
            let view = AboutView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
            
        case .helpTappedFromMenu:
                 
            let helpWebContent = HelpWebContent(localizationServices: appDiContainer.localizationServices)
            
            navigateToWebContentView(webContent: helpWebContent)
            
        case .contactUsTappedFromMenu:
           
            if MFMailComposeViewController.canSendMail() {
                
                let finishedSendingMail = CallbackHandler { [weak self] in
                    self?.navigationController.dismiss(animated: true, completion: nil)
                }
                
                let viewModel = MailViewModel(
                    toRecipients: ["support@godtoolsapp.com"],
                    subject: "Email to GodTools support",
                    message: "",
                    isHtml: false,
                    finishedSendingMailHandler: finishedSendingMail
                )
                
                let view = MailView(viewModel: viewModel)
                
                navigationController.present(view, animated: true, completion: nil)
            }
            else {
                let contactUsWebContent = ContactUsWebContent(localizationServices: appDiContainer.localizationServices)
                navigateToWebContentView(webContent: contactUsWebContent)
            }
            
        case .shareGodToolsTappedFromMenu:
            
            let textToShare: String = appDiContainer.localizationServices.stringForMainBundle(key: "share_god_tools_share_sheet_text")
            let view = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            
            navigationController.present(view, animated: true, completion: nil)
            
        case .shareAStoryWithUsTappedFromMenu:
            
            if MFMailComposeViewController.canSendMail() {
                
                let finishedSendingMail = CallbackHandler { [weak self] in
                    self?.navigationController.dismiss(animated: true, completion: nil)
                }
                
                let viewModel = MailViewModel(
                    toRecipients: ["support@godtoolsapp.com"],
                    subject: "GodTools story",
                    message: "",
                    isHtml: false,
                    finishedSendingMailHandler: finishedSendingMail
                )
                
                let view = MailView(viewModel: viewModel)
                
                navigationController.present(view, animated: true, completion: nil)
            }
            else {
                
                let shareStoryWebContent = ShareAStoryWithUsWebContent(localizationServices: appDiContainer.localizationServices)
                
                navigateToWebContentView(webContent: shareStoryWebContent)
            }
            
        case .termsOfUseTappedFromMenu:
            
            let termsOfUserWebContent = TermsOfUseWebContent(localizationServices: appDiContainer.localizationServices)
            
            navigateToWebContentView(webContent: termsOfUserWebContent)
            
        case .privacyPolicyTappedFromMenu:
            
            let privacyPolicyWebContent = PrivacyPolicyWebContent(localizationServices: appDiContainer.localizationServices)
            
            navigateToWebContentView(webContent: privacyPolicyWebContent)
            
        case .copyrightInfoTappedFromMenu:
            
            let copyrightInfoWebContent = CopyrightInfoWebContent(localizationServices: appDiContainer.localizationServices)
            
            navigateToWebContentView(webContent: copyrightInfoWebContent)
            
        case .logoutTappedFromMenu(let logoutHandler):
            
            let localizationServices: LocalizationServices = appDiContainer.localizationServices
            
            let viewModel = AlertMessageViewModel(
                title: "Proceed with GodTools logout?",
                message: "You are about to logout of your GodTools account",
                cancelTitle: localizationServices.stringForMainBundle(key: "cancel"),
                acceptTitle: localizationServices.stringForMainBundle(key: "OK"),
                acceptHandler: logoutHandler
            )
            let view = AlertMessageView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
        
        case .playgroundTappedFromMenu:
            
            //let viewModel = PlaygroundViewModel()
            //let view = PlaygroundView(viewModel: viewModel)
    
            // TODO: Remove. ~Levi
                        
            let translationDownloader = appDiContainer.translationDownloader
            let location = SHA256FileLocation(sha256WithPathExtension: "8bd5fe81f37c7eddeb36f980a3330269a9ef4f66e0063fdfd4065d527d1827c0.xml")
            
            var tipXml: Data!
            
            switch translationDownloader.translationsFileCache.getData(location: location) {
            case .success(let xmlData):
                tipXml = xmlData!
            case .failure(let error):
                break
            }
            
            //end remove
            
            let viewModel = ToolTrainingViewModel(
                tipXml: tipXml,
                tipRenderer: appDiContainer.getTipRenderer()
            )
            
            let view = ToolTrainingView(viewModel: viewModel)
                        
            navigationController.present(view, animated: true, completion: nil)
            
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
