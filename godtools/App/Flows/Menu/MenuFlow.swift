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
import Combine

class MenuFlow: Flow {
    
    private var tutorialFlow: TutorialFlow?
    private var languageSettingsFlow: LanguageSettingsFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        
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
        
        let view: UIViewController = getMenuView()
        
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
            flowDelegate?.navigate(step: .doneTappedFromMenu)
            
        case .loginTappedFromMenu(let authenticationCompletedSubject):
            let view = getSocialSignInView(authenticationType: .login, authenticationCompletedSubject: authenticationCompletedSubject)
            navigationController.present(view, animated: true)
            
        case .closeTappedFromLogin:
            navigationController.dismiss(animated: true)
            
        case .createAccountTappedFromMenu(let authenticationCompletedSubject):
            let view = getSocialSignInView(authenticationType: .createAccount, authenticationCompletedSubject: authenticationCompletedSubject)
            navigationController.present(view, animated: true)
            
        case .closeTappedFromCreateAccount:
            navigationController.dismiss(animated: true)
                                
        case .userCompletedSignInFromCreateAccount(let error):
            navigationController.dismissPresented(animated: true) {
                if let error = error {
                    self.presentError(error: error)
                }
            }
            
        case .userCompletedSignInFromLogin(let error):
            navigationController.dismissPresented(animated: true) {
                if let error = error {
                    self.presentError(error: error)
                }
            }
            
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
            
            let appleAppId: String = appDiContainer.dataLayer.getAppConfig().appleAppId
            
            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(appleAppId)?action=write-review") else {
                let error: Error = NSError.errorWithDescription(description: "Failed to open to apple review.  Invalid URL.")
                presentError(error: error)
                return
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
            navigationController.present(getDeleteAccountView(), animated: true)
            
        case .closeTappedFromDeleteAccount:
            navigationController.dismissPresented(animated: true, completion: nil)
            
        case .deleteAccountTappedFromDeleteAccount:
            navigationController.dismissPresented(animated: true) {
                self.navigationController.present(self.getConfirmDeleteAccountView(), animated: true)
            }
                        
        case .deleteAccountTappedFromConfirmDeleteAccount:
            navigationController.present(self.getDeleteAccountProgressView(), animated: true)
                    
        case .cancelTappedFromDeleteAccount:
            navigationController.dismissPresented(animated: true, completion: nil)

        case .didFinishAccountDeletionWithSuccessFromDeleteAccountProgress:
            
            let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
            
            navigationController.dismissPresented(animated: true) {
                
                let title: String = localizationServices.stringForMainBundle(key: "accountDeletedAlert.title")
                let message: String = localizationServices.stringForMainBundle(key: "accountDeletedAlert.message")
                
                self.presentAlert(title: title, message: message)
            }
            
        case .didFinishAccountDeletionWithErrorFromDeleteAccountProgress(let error):
            navigationController.dismissPresented(animated: true) {
                self.presentError(error: error)
            }
                        
        default:
            break
        }
    }
    
    private func getMenuView() -> UIViewController {
        
        /*
        let viewModel = LegacyMenuViewModel(
            flowDelegate: self,
            infoPlist: appDiContainer.dataLayer.getInfoPlist(),
            getAccountCreationIsSupportedUseCase: appDiContainer.domainLayer.getAccountCreationIsSupportedUseCase(),
            logOutUserUseCase: appDiContainer.domainLayer.getLogOutUserUseCase(),
            getUserIsAuthenticatedUseCase: appDiContainer.domainLayer.getUserIsAuthenticatedUseCase(),
            localizationServices: appDiContainer.localizationServices,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            getOptInOnboardingTutorialAvailableUseCase: appDiContainer.getOptInOnboardingTutorialAvailableUseCase(),
            disableOptInOnboardingBannerUseCase: appDiContainer.getDisableOptInOnboardingBannerUseCase()
        )
        
        let view = LegacyMenuView(viewModel: viewModel)
        
        return view*/
    
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        
        let viewModel = MenuViewModel(
            flowDelegate: self,
            localizationServices: localizationServices,
            analytics: appDiContainer.dataLayer.getAnalytics(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getOptInOnboardingTutorialAvailableUseCase: appDiContainer.getOptInOnboardingTutorialAvailableUseCase(),
            disableOptInOnboardingBannerUseCase: appDiContainer.getDisableOptInOnboardingBannerUseCase(),
            logOutUserUseCase: appDiContainer.domainLayer.getLogOutUserUseCase(),
            getAppVersionUseCase: appDiContainer.domainLayer.getAppVersionUseCase()
        )
        
        let view = MenuView(viewModel: viewModel)
        
        let hostingView: UIHostingController<MenuView> = UIHostingController(rootView: view)
        
        _ = hostingView.addBarButtonItem(
            to: .right,
            title: localizationServices.stringForMainBundle(key: "done"),
            style: .done,
            color: nil,
            target: viewModel,
            action: #selector(viewModel.doneTapped)
        )
        
        return hostingView
    }
    
    private func getSocialSignInView(authenticationType: SocialSignInAuthenticationType, authenticationCompletedSubject: PassthroughSubject<Void, Never>) -> UIViewController {
        
        let viewBackgroundColor: Color = ColorPalette.gtBlue.color
        let viewBackgroundUIColor: UIColor = UIColor(viewBackgroundColor)
        
        let viewModel = SocialSignInViewModel(
            flowDelegate: self,
            presentAuthViewController: navigationController,
            authenticationType: authenticationType,
            authenticationCompletedSubject: authenticationCompletedSubject,
            authenticateUserUseCase: appDiContainer.domainLayer.getAuthenticateUserUseCase(),
            localizationServices: appDiContainer.localizationServices
        )
        
        let view = SocialSignInView(viewModel: viewModel, backgroundColor: viewBackgroundColor)
        
        let hostingView: UIHostingController<SocialSignInView> = UIHostingController(rootView: view)
        
        hostingView.view.backgroundColor = viewBackgroundUIColor
        
        _ = hostingView.addBarButtonItem(
            to: .right,
            image: ImageCatalog.navClose.uiImage,
            color: .white,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
        )
        
        let modal: ModalNavigationController = ModalNavigationController(
            rootView: hostingView,
            navBarColor: viewBackgroundUIColor,
            navBarIsTranslucent: false,
            controlColor: .white,
            statusBarStyle: .lightContent
        )
        
        modal.view.backgroundColor = viewBackgroundUIColor
                
        return modal
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
    
    private func getDeleteAccountView() -> UIViewController {
        
        let viewBackgroundColor: Color = Color.white
        let viewBackgroundUIColor: UIColor = UIColor(viewBackgroundColor)
        
        let viewModel = DeleteAccountViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.dataLayer.getLocalizationServices()
        )
        
        let view = DeleteAccountView(viewModel: viewModel, backgroundColor: viewBackgroundColor)
        
        let hostingView: UIHostingController<DeleteAccountView> = UIHostingController(rootView: view)
        
        hostingView.view.backgroundColor = viewBackgroundUIColor
        
        _ = hostingView.addBarButtonItem(
            to: .right,
            image: ImageCatalog.navClose.uiImage,
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
        )
        
        let modal: ModalNavigationController = ModalNavigationController(
            rootView: hostingView,
            navBarColor: viewBackgroundUIColor,
            navBarIsTranslucent: false,
            controlColor: ColorPalette.gtBlue.uiColor,
            statusBarStyle: .darkContent
        )
        
        modal.view.backgroundColor = viewBackgroundUIColor
                
        return modal
    }
    
    private func getConfirmDeleteAccountView() -> UIViewController {
        
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        
        let viewController = UIAlertController(
            title: localizationServices.stringForMainBundle(key: "confirmDeleteAccount.title"),
            message: "",
            preferredStyle: .actionSheet
        )
        
        viewController.addAction(UIAlertAction(title: localizationServices.stringForMainBundle(key: "confirmDeleteAccount.confirmButton.title"), style: .destructive, handler: { (action: UIAlertAction) in
                        
            self.navigate(step: .deleteAccountTappedFromConfirmDeleteAccount)
        }))
        
        viewController.addAction(UIAlertAction(title: localizationServices.stringForMainBundle(key: "cancel"), style: .cancel, handler: { (action: UIAlertAction) in
            
        }))
        
        return viewController
    }
    
    private func getDeleteAccountProgressView() -> UIViewController {
        
        let viewBackgroundColor: Color = Color.white
        let viewBackgroundUIColor: UIColor = UIColor(viewBackgroundColor)
        
        let viewModel = DeleteAccountProgressViewModel(
            flowDelegate: self,
            deleteAccountUseCase: appDiContainer.domainLayer.getDeleteAccountUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices()
        )
        
        let view = DeleteAccountProgressView(viewModel: viewModel, backgroundColor: viewBackgroundColor)
        
        let hostingView: UIHostingController<DeleteAccountProgressView> = UIHostingController(rootView: view)
        
        hostingView.view.backgroundColor = viewBackgroundUIColor
        
        let modal: ModalNavigationController = ModalNavigationController(
            rootView: hostingView,
            navBarColor: viewBackgroundUIColor,
            navBarIsTranslucent: false,
            controlColor: ColorPalette.gtBlue.uiColor,
            statusBarStyle: .darkContent
        )
        
        modal.view.backgroundColor = viewBackgroundUIColor
                
        return modal
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
