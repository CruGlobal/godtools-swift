//
//  MenuFlow.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import MessageUI
import SwiftUI

class MenuFlow: Flow {
    
    private var tutorialFlow: TutorialFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        
        let fontService: FontService = appDiContainer.getFontService()
        
        navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(false, animated: false)
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: ColorPalette.gtBlue.uiColor,
            controlColor: .white,
            titleFont: fontService.getFont(size: 17, weight: .semibold),
            titleColor: .white,
            isTranslucent: false
        )
        
        let viewModel = MenuViewModel(
            flowDelegate: self,
            infoPlist: appDiContainer.dataLayer.getInfoPlist(),
            getAccountCreationIsSupportedUseCase: appDiContainer.domainLayer.getAccountCreationIsSupportedUseCase(),
            authenticateUserUseCase: appDiContainer.domainLayer.getAuthenticateUserUseCase(),
            logOutUserUseCase: appDiContainer.domainLayer.getLogOutUserUseCase(),
            getUserIsAuthenticatedUseCase: appDiContainer.domainLayer.getUserIsAuthenticatedUseCase(),
            localizationServices: appDiContainer.localizationServices,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            getOptInOnboardingTutorialAvailableUseCase: appDiContainer.getOptInOnboardingTutorialAvailableUseCase(),
            disableOptInOnboardingBannerUseCase: appDiContainer.getDisableOptInOnboardingBannerUseCase()
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
            navigateToTutorial()
            
        case .closeTappedFromTutorial:
            dismissTutorial()
            
        case .startUsingGodToolsTappedFromTutorial:
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
            dismissTutorial()
            
        case .doneTappedFromMenu:
            print(" menu flow done tapped")
            flowDelegate?.navigate(step: .doneTappedFromMenu)
                        
        case .myAccountTappedFromMenu:
            navigationController.pushViewController(getAccountView(), animated: true)
            
        case .backTappedFromMyAccount:
            navigationController.popViewController(animated: true)
            
        case .aboutTappedFromMenu:
            navigationController.pushViewController(getAboutView(), animated: true)
            
        case .backTappedFromAbout:
            navigationController.popViewController(animated: true)
            
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
                
                navigateToNativeMailApp(viewModel: viewModel)
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
                
                navigateToNativeMailApp(viewModel: viewModel)                
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
            
        case .deleteAccountTappedFromMenu:
            
            let viewModel = DeleteAccountViewModel(
                flowDelegate: self,
                localizationServices: appDiContainer.localizationServices
            )
            
            let view = DeleteAccountView(viewModel: viewModel)
            
            let hostingView = DeleteAccountHostingView(view: view)
                        
            navigationController.pushViewController(hostingView, animated: true)
            
        case .backTappedFromDeleteAccount:
            
            navigationController.popViewController(animated: true)
            
        case .emailHelpDeskToDeleteOktaAccountTappedFromDeleteAccount:
            
            let finishedSendingMail = CallbackHandler { [weak self] in
                self?.navigationController.dismiss(animated: true, completion: nil)
            }
            
            let viewModel = MailViewModel(
                toRecipients: ["help@cru.org"],
                subject: "Please delete my account",
                message: "I have created an account on the GodTools app and I would like to request that you delete my Okta account.",
                isHtml: false,
                finishedSendingMailHandler: finishedSendingMail
            )
            
            navigateToNativeMailApp(viewModel: viewModel)
                        
        default:
            break
        }
    }
    
    private func getAboutView() -> UIViewController {
        
        let viewModel = AboutViewModel(
            flowDelegate: self,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.dataLayer.getAnalytics()
        )
        
        let view = AboutView(viewModel: viewModel)
        
        let hostingView: UIHostingController<AboutView> = UIHostingController(rootView: view)
        
        _ = hostingView.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        return hostingView
    }
    
    private func getAccountView() -> UIViewController {
        
        let viewModel = AccountViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getUserAccountProfileNameUseCase: appDiContainer.domainLayer.getUserAccountProfileNameUseCase(),
            getUserAccountDetailsUseCase: appDiContainer.domainLayer.getUserAccountDetailsUseCase(),
            getGlobalActivityThisWeekUseCase: appDiContainer.domainLayer.getGlobalActivityThisWeekUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics()
        )
        
        let view = AccountView(viewModel: viewModel)
        
        let hostingView: UIHostingController<AccountView> = UIHostingController(rootView: view)
        
        _ = hostingView.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        return hostingView
    }
    
    private func getWebContentView(webContent: WebContentType) -> UIViewController {
        
        let viewModel = WebContentViewModel(
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            webContent: webContent
        )
        
        let view = WebContentView(viewModel: viewModel)
        
        return view
    }
    
    private func navigateToWebContentView(webContent: WebContentType) {
        
        navigationController.pushViewController(getWebContentView(webContent: webContent), animated: true)
    }
}

// MARK: - Tutorial

extension MenuFlow {
    
    private func navigateToTutorial() {
        
        let tutorialFlow = TutorialFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: nil
        )
        
        navigationController.present(tutorialFlow.navigationController, animated: true, completion: nil)
        
        self.tutorialFlow = tutorialFlow
    }
    
    private func dismissTutorial() {
        
        guard tutorialFlow != nil else {
            return
        }
        
        navigationController.dismiss(animated: true, completion: nil)
        
        self.tutorialFlow = nil
    }
}
