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
    private var cancellables: Set<AnyCancellable> = Set()
    
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
            
        case .loginTappedFromMenu:
            let view = getSocialSignInView(authenticationType: .login)
            navigationController.present(view, animated: true)
            
        case .closeTappedFromLogin:
            navigationController.dismiss(animated: true)
            
        case .createAccountTappedFromMenu:
            let view = getSocialSignInView(authenticationType: .createAccount)
            navigationController.present(view, animated: true)
            
        case .closeTappedFromCreateAccount:
            navigationController.dismiss(animated: true)
            
        case .loginWithFacebookTapped:
            authenticateUser(provider: .facebook, createUser: false)
            
        case .loginWithGoogleTapped:
            authenticateUser(provider: .google, createUser: false)
            
        case .loginWithAppleTapped:
            authenticateUser(provider: .apple, createUser: false)
            
        case .createAccountWithFacebookTapped:
            authenticateUser(provider: .facebook, createUser: true)
            
        case .createAccountWithGoogleTapped:
            authenticateUser(provider: .google, createUser: true)
            
        case .createAccountWithAppleTapped:
            authenticateUser(provider: .apple, createUser: true)
                        
        case .userCompletedAuthentication(let error):
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
            print("deleting account...")
            assertionFailure("TODO: Implement delete account use case in GT-2010...")
        
        case .cancelTappedFromDeleteAccount:
            navigationController.dismissPresented(animated: true, completion: nil)
                        
        default:
            break
        }
    }
    
    private func getMenuView() -> UIViewController {
        
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
        
        return view
        
        
        /*
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        
        let viewModel = MenuViewModel(
            flowDelegate: self,
            localizationServices: localizationServices
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
        
        return hostingView*/
    }
    
    private func getSocialSignInView(authenticationType: SocialSignInAuthenticationType) -> UIViewController {
        
        let viewBackgroundColor: Color = ColorPalette.gtBlue.color
        let viewBackgroundUIColor: UIColor = UIColor(viewBackgroundColor)
        
        let viewModel = SocialSignInViewModel(
            flowDelegate: self,
            authenticationType: authenticationType,
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
    
    private func authenticateUser(provider: AuthenticationProviderType, createUser: Bool) {
        
        let authenticateUserUseCase: AuthenticateUserUseCase = appDiContainer.domainLayer.getAuthenticateUserUseCase()
        
        let presentAuthFromViewController: UIViewController = navigationController.getTopMostPresentedViewController() ?? navigationController
        
        authenticateUserUseCase.authenticatePublisher(provider: provider, policy: .renewAccessTokenElseAskUserToAuthenticate(fromViewController: presentAuthFromViewController))
            .receiveOnMain()
            .sink { [weak self] subscriberCompletion in
                
                let authenticationError: Error?
                
                switch subscriberCompletion {
                    
                case .finished:
                    authenticationError = nil
                    
                case .failure(let error):
                    authenticationError = error
                }
                
                self?.navigate(step: .userCompletedAuthentication(error: authenticationError))
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
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
