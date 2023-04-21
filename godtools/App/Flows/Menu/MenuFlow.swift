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
            navigateToLanguageSettings()
            
        case .languageSettingsFlowCompleted( _):
            closeLanguageSettings()
            
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
            
        case .loginTappedFromMenu:
            navigationController.pushViewController(getSocialSignInView(), animated: true)
                        
        case .activityTappedFromMenu:
            navigationController.pushViewController(getAccountView(), animated: true)
            
        case .backTappedFromActivity:
            navigationController.popViewController(animated: true)

        case .shareGodToolsTappedFromMenu:

            let textToShare: String = appDiContainer.localizationServices.stringForMainBundle(key: "share_god_tools_share_sheet_text")
            let view = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)

            navigationController.present(view, animated: true, completion: nil)
            
        case .sendFeedbackTappedFromMenu:
            let sendFeedbackWebContent = SendFeedbackWebContent(localizationServices: appDiContainer.localizationServices)
            
            pushWebContentView(webContent: sendFeedbackWebContent, backTappedFromWebContentStep: .backTappedFromSendFeedback)
            
        case .backTappedFromSendFeedback:
            navigationController.popViewController(animated: true)
            
        case .reportABugTappedFromMenu:
            let reportABugWebContent = ReportABugWebContent(localizationServices: appDiContainer.localizationServices)
            
            pushWebContentView(webContent: reportABugWebContent, backTappedFromWebContentStep: .backTappedFromReportABug)
            
        case .backTappedFromReportABug:
            navigationController.popViewController(animated: true)
            
        case .askAQuestionTappedFromMenu:
            let askAQuestionWebContent = AskAQuestionWebContent(localizationServices: appDiContainer.localizationServices)
            
            pushWebContentView(webContent: askAQuestionWebContent, backTappedFromWebContentStep: .backTappedFromAskAQuestion)
            
        case .backTappedFromAskAQuestion:
            navigationController.popViewController(animated: true)
            
        case .leaveAReviewTappedFromMenu:
            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id542773210?action=write-review") else {
                fatalError("Expected a valid URL")
            }
            
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
            
        case .shareAStoryWithUsTappedFromMenu:
            let shareStoryWebContent = ShareAStoryWithUsWebContent(localizationServices: appDiContainer.localizationServices)
            
            pushWebContentView(webContent: shareStoryWebContent, backTappedFromWebContentStep: .backTappedFromShareAStoryWithUs)
            
        case .backTappedFromShareAStoryWithUs:
            navigationController.popViewController(animated: true)
            
        case .termsOfUseTappedFromMenu:
            
            let termsOfUserWebContent = TermsOfUseWebContent(localizationServices: appDiContainer.localizationServices)
            
            pushWebContentView(webContent: termsOfUserWebContent, backTappedFromWebContentStep: .backTappedFromTermsOfUse)
            
        case .backTappedFromTermsOfUse:
            navigationController.popViewController(animated: true)
            
        case .privacyPolicyTappedFromMenu:
            
            let privacyPolicyWebContent = PrivacyPolicyWebContent(localizationServices: appDiContainer.localizationServices)
            
            pushWebContentView(webContent: privacyPolicyWebContent, backTappedFromWebContentStep: .backTappedFromPrivacyPolicy)
            
        case .backTappedFromPrivacyPolicy:
            navigationController.popViewController(animated: true)
            
        case .copyrightInfoTappedFromMenu:
            
            let copyrightInfoWebContent = CopyrightInfoWebContent(localizationServices: appDiContainer.localizationServices)
            
            pushWebContentView(webContent: copyrightInfoWebContent, backTappedFromWebContentStep: .backTappedFromCopyrightInfo)
            
        case .backTappedFromCopyrightInfo:
            navigationController.popViewController(animated: true)
            
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
    
    private func getSocialSignInView() -> UIViewController {
        
        let viewModel = SocialSignInViewModel(
            localizationServices: appDiContainer.localizationServices
        )
        
        let view = SocialSignInView(viewModel: viewModel)
        
        let hostingView: UIHostingController<SocialSignInView> = UIHostingController(rootView: view)
        
//        _ = hostingView.addDefaultNavBackItem(
//            target: viewModel,
//            action: #selector(viewModel.backTapped)
//        )
        
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
            getUserActivityUseCase: appDiContainer.domainLayer.getUserActivityUseCase(),
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
    
    private func getWebContentView(webContent: WebContentType, backTappedFromWebContentStep: FlowStep) -> UIViewController {
        
        let viewModel = WebContentViewModel(
            flowDelegate: self,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            webContent: webContent,
            backTappedFromWebContentStep: backTappedFromWebContentStep
        )
        
        let view = WebContentView(viewModel: viewModel)
        
        _ = view.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        return view
    }
    
    private func pushWebContentView(webContent: WebContentType, backTappedFromWebContentStep: FlowStep) {
        
        let view = getWebContentView(
            webContent: webContent,
            backTappedFromWebContentStep: backTappedFromWebContentStep
        )
        
        navigationController.pushViewController(view, animated: true)
    }
}

// MARK: - Language Settings

extension MenuFlow {
    
    private func navigateToLanguageSettings() {
        
        let languageSettingsFlow = LanguageSettingsFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController
        )
        
        self.languageSettingsFlow = languageSettingsFlow
    }
    
    private func closeLanguageSettings() {
        
        guard languageSettingsFlow != nil else {
            return
        }
        
        navigationController.popViewController(animated: true)
        
        self.languageSettingsFlow = nil
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
