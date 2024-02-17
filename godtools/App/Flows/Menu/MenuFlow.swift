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
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        
        let fontService: FontService = appDiContainer.getFontService()
        
        let navigationBarAppearance = AppNavigationBarAppearance(
            backgroundColor: ColorPalette.gtBlue.uiColor,
            controlColor: .white,
            titleFont: fontService.getFont(size: 17, weight: .semibold),
            titleColor: .white,
            isTranslucent: false
        )
        
        navigationController = AppNavigationController(navigationBarAppearance: navigationBarAppearance)
        navigationController.setNavigationBarHidden(false, animated: false)
        
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
                                
        case .userCompletedSignInFromCreateAccount(let error):
            navigationController.dismissPresented(animated: true) {
                if let error = error {
                    self.presentAlertMessage(alertMessage: self.getAuthErrorAlertMessage(authError: error))
                }
            }
            
        case .userCompletedSignInFromLogin(let error):
            navigationController.dismissPresented(animated: true) {
                if let error = error {
                    self.presentAlertMessage(alertMessage: self.getAuthErrorAlertMessage(authError: error))
                }
            }
            
        case .activityTappedFromMenu:
            navigationController.pushViewController(getAccountView(), animated: true)
            
        case .backTappedFromActivity:
            navigationController.popViewController(animated: true)

        case .shareGodToolsTappedFromMenu:

            let textToShare: String = appDiContainer.dataLayer.getLocalizationServices().stringForSystemElseEnglish(key: "share_god_tools_share_sheet_text")
            let view = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)

            navigationController.present(view, animated: true, completion: nil)
            
        case .sendFeedbackTappedFromMenu:
            let sendFeedbackWebContent = SendFeedbackWebContent(localizationServices: appDiContainer.dataLayer.getLocalizationServices())
            
            pushWebContentView(webContent: sendFeedbackWebContent, backTappedFromWebContentStep: .backTappedFromSendFeedback)
            
        case .backTappedFromSendFeedback:
            navigationController.popViewController(animated: true)
            
        case .reportABugTappedFromMenu:
            let reportABugWebContent = ReportABugWebContent(localizationServices: appDiContainer.dataLayer.getLocalizationServices())
            
            pushWebContentView(webContent: reportABugWebContent, backTappedFromWebContentStep: .backTappedFromReportABug)
            
        case .backTappedFromReportABug:
            navigationController.popViewController(animated: true)
            
        case .askAQuestionTappedFromMenu:
            let askAQuestionWebContent = AskAQuestionWebContent(localizationServices: appDiContainer.dataLayer.getLocalizationServices())
            
            pushWebContentView(webContent: askAQuestionWebContent, backTappedFromWebContentStep: .backTappedFromAskAQuestion)
            
        case .backTappedFromAskAQuestion:
            navigationController.popViewController(animated: true)
            
        case .leaveAReviewTappedFromMenu(let screenName, let siteSection, let siteSubSection, let contentLanguage, let contentLanguageSecondary):
            
            let appleAppId: String = appDiContainer.dataLayer.getAppConfig().getAppleAppId()
            
            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(appleAppId)?action=write-review") else {
                let error: Error = NSError.errorWithDescription(description: "Failed to open to apple review.  Invalid URL.")
                presentError(error: error)
                return
            }
            
            navigateToURL(url: writeReviewURL, screenName: screenName, siteSection: siteSection, siteSubSection: siteSubSection, contentLanguage: contentLanguage, contentLanguageSecondary: contentLanguageSecondary)
            
        case .shareAStoryWithUsTappedFromMenu:
            let shareStoryWebContent = ShareAStoryWithUsWebContent(localizationServices: appDiContainer.dataLayer.getLocalizationServices())
            
            pushWebContentView(webContent: shareStoryWebContent, backTappedFromWebContentStep: .backTappedFromShareAStoryWithUs)
            
        case .backTappedFromShareAStoryWithUs:
            navigationController.popViewController(animated: true)
            
        case .termsOfUseTappedFromMenu:
            
            let termsOfUserWebContent = TermsOfUseWebContent(localizationServices: appDiContainer.dataLayer.getLocalizationServices())
            
            pushWebContentView(webContent: termsOfUserWebContent, backTappedFromWebContentStep: .backTappedFromTermsOfUse)
            
        case .backTappedFromTermsOfUse:
            navigationController.popViewController(animated: true)
            
        case .privacyPolicyTappedFromMenu:
            
            let privacyPolicyWebContent = PrivacyPolicyWebContent(localizationServices: appDiContainer.dataLayer.getLocalizationServices())
            
            pushWebContentView(webContent: privacyPolicyWebContent, backTappedFromWebContentStep: .backTappedFromPrivacyPolicy)
            
        case .backTappedFromPrivacyPolicy:
            navigationController.popViewController(animated: true)
            
        case .copyrightInfoTappedFromMenu:
            
            let copyrightInfoWebContent = CopyrightInfoWebContent(localizationServices: appDiContainer.dataLayer.getLocalizationServices())
            
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
                
                let title: String = localizationServices.stringForSystemElseEnglish(key: "accountDeletedAlert.title")
                let message: String = localizationServices.stringForSystemElseEnglish(key: "accountDeletedAlert.message")
                
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
            
        let viewModel = MenuViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getMenuInterfaceStringsUseCase: appDiContainer.domainLayer.getMenuInterfaceStringsUseCase(),
            getOptInOnboardingTutorialAvailableUseCase: appDiContainer.domainLayer.getOptInOnboardingTutorialAvailableUseCase(),
            disableOptInOnboardingBannerUseCase: appDiContainer.domainLayer.getDisableOptInOnboardingBannerUseCase(),
            getAccountCreationIsSupportedUseCase: appDiContainer.domainLayer.getAccountCreationIsSupportedUseCase(),
            getUserIsAuthenticatedUseCase: appDiContainer.domainLayer.getUserIsAuthenticatedUseCase(),
            logOutUserUseCase: appDiContainer.domainLayer.getLogOutUserUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = MenuView(viewModel: viewModel)
        
        let doneButton = AppInterfaceStringBarItem(
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            localizedStringKey: "done",
            style: .done,
            color: nil,
            target: viewModel,
            action: #selector(viewModel.doneTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: [doneButton]
            )
        )
        
        return hostingView
    }
    
    private func getSocialSignInView(authenticationType: SocialSignInAuthenticationType) -> UIViewController {
        
        let viewBackgroundColor: Color = ColorPalette.gtBlue.color
        let viewBackgroundUIColor: UIColor = UIColor(viewBackgroundColor)
        
        let viewModel = SocialSignInViewModel(
            flowDelegate: self,
            presentAuthViewController: navigationController,
            authenticationType: authenticationType,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getSocialCreateAccountInterfaceStringsUseCase: appDiContainer.feature.accountCreation.domainLayer.getSocialCreateAccountInterfaceStringsUseCase(),
            getSocialSignInInterfaceStringsUseCase: appDiContainer.feature.accountCreation.domainLayer.getSocialSignInInterfaceStringsUseCase(),
            authenticateUserUseCase: appDiContainer.feature.accountCreation.domainLayer.getAuthenticateUserUseCase()
        )
        
        let view = SocialSignInView(viewModel: viewModel, backgroundColor: viewBackgroundColor)
        
        let closeButton = AppCloseBarItem(
            color: .white,
            target: viewModel,
            action: #selector(viewModel.closeTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<SocialSignInView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: [closeButton]
            )
        )
                
        hostingView.view.backgroundColor = viewBackgroundUIColor
        
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
    
    private func getAuthErrorAlertMessage(authError: AuthErrorDomainModel) -> AlertMessageType {
        
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        let message: String
        
        switch authError {
        case .accountAlreadyExists:
            message = localizationServices.stringForSystemElseEnglish(key: "authError.userAccountAlreadyExists.message")
            
        case .accountNotFound:
            message = localizationServices.stringForSystemElseEnglish(key: "authError.userAccountNotFound.message")
            
        case .other(let error):
            message = error.localizedDescription
        }
        
        return AlertMessage(
            title: "",
            message: message
        )
    }
    
    private func getAccountView() -> UIViewController {
        
        let viewModel = AccountViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getUserAccountDetailsUseCase: appDiContainer.domainLayer.getUserAccountDetailsUseCase(),
            getUserActivityUseCase: appDiContainer.domainLayer.getUserActivityUseCase(),
            getGlobalActivityThisWeekUseCase: appDiContainer.domainLayer.getGlobalActivityThisWeekUseCase(),
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(), 
            viewAccountUseCase: appDiContainer.domainLayer.getViewAccountUseCase()
        )
        
        let view = AccountView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<AccountView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
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
        
        let closeButton = AppCloseBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<DeleteAccountView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: [closeButton]
            )
        )
                
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
    
    private func getConfirmDeleteAccountView() -> UIViewController {
        
        let localizationServices: LocalizationServices = appDiContainer.dataLayer.getLocalizationServices()
        
        let viewController = UIAlertController(
            title: localizationServices.stringForSystemElseEnglish(key: "confirmDeleteAccount.title"),
            message: "",
            preferredStyle: .actionSheet
        )
        
        viewController.addAction(UIAlertAction(title: localizationServices.stringForSystemElseEnglish(key: "confirmDeleteAccount.confirmButton.title"), style: .destructive, handler: { (action: UIAlertAction) in
                        
            self.navigate(step: .deleteAccountTappedFromConfirmDeleteAccount)
        }))
        
        viewController.addAction(UIAlertAction(title: localizationServices.stringForSystemElseEnglish(key: "cancel"), style: .cancel, handler: { (action: UIAlertAction) in
            
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
        
        let hostingView = AppHostingController<DeleteAccountProgressView>(
            rootView: view,
            navigationBar: nil
        )
                
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
            webContent: webContent,
            backTappedFromWebContentStep: backTappedFromWebContentStep,
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let view = WebContentView(
            viewModel: viewModel,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
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
