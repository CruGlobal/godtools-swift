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

final class MenuFlow: GTFlow {
            
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel
                
    init(appDiContainer: AppDiContainer, appLanguage: AppLanguageDomainModel, initialNavigationStep: AppFlowStep? = nil) {
        
        self.appLanguage = appLanguage
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: nil,
            stepEmitter: stepEmitter,
            navigationController: AppNavigationController(
                navigationBarAppearance: AppNavigationBarAppearance(
                    backgroundColor: AppFlow.defaultNavBarColor,
                    controlColor: AppFlow.defaultNavBarControlColor,
                    titleFont: FontLibrary.systemUIFont(size: 17, weight: .semibold),
                    titleColor: AppFlow.defaultNavBarControlColor,
                    isTranslucent: false
                )
            )
        )
        
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.setViewControllers([getMenuView(appLanguage: appLanguage)], animated: false)
                                
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        if let initialNavigationStep = initialNavigationStep {
            navigate(step: initialNavigationStep)
        }
    }
    
    var view: UIView {
        return navigationController.view
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
            
        case .languageSettingsTappedFromMenu:
            pushFlow(
                flow: LanguageSettingsFlow(
                    appDiContainer: appDiContainer,
                    deepLink: nil
                )
            )
            
        case .languageSettingsFlowCompleted( _):
            popFlow()
            
        case .localizationSettingsTappedFromMenu:
            pushFlow(
                flow: LocalizationSettingsFlow(
                    appDiContainer: appDiContainer,
                    shouldStoreCountryWhenSelected: true,
                    userShouldConfirmSelectedCountry: true
                )
            )

        case .localizationSettingsFlowCompleted( _):
            popFlow()
            
        case .tutorialTappedFromMenu:
            presentFlow(
                flow: TutorialFlow(appDiContainer: appDiContainer)
            )
            
        case .tutorialFlowCompleted( _):
            dismissFlow()
            
        case .doneTappedFromMenu:
            parent?.stepEmitter.emit(step: AppFlowStep.doneTappedFromMenu)
            
        case .loginTappedFromMenu:
            
            presentView(
                view: getSocialSignInView(authenticationType: .login),
                animated: true
            )
            
        case .closeTappedFromLogin:
            dismissView(animated: true)
            
        case .createAccountTappedFromMenu:
            
            presentView(
                view: getSocialSignInView(authenticationType: .createAccount),
                animated: true
            )
            
        case .closeTappedFromCreateAccount:
            dismissView(animated: true)
                                
        case .userCompletedSignInFromCreateAccount(let authError):
                        
            dismissView(animated: true, completion: { [weak self] in
                if let authError = authError {
                    self?.presentSocialAuthError(authError: authError)
                }
            })
            
        case .userCompletedSignInFromLogin(let authError):
            
            dismissView(animated: true, completion: { [weak self] in
                if let authError = authError {
                    self?.presentSocialAuthError(authError: authError)
                }
            })
            
        case .activityTappedFromMenu:
            navigationController.pushViewController(getAccountView(), animated: true)
            
        case .backTappedFromActivity:
            navigationController.popViewController(animated: true)

        case .shareGodToolsTappedFromMenu:
            
            presentView(
                view: getShareGodToolsView(),
                animated: true
            )
            
        case .dismissedShareGodToolsActivityViewController:
            // NOTE: Nothing to do here since UIActivityViewController dismisses itself. ~Levi
            break
            
        case .sendFeedbackTappedFromMenu:
            let sendFeedbackWebContent = SendFeedbackWebContent(localizationServices: appDiContainer.core.dataLayer.getLocalizationServices())
            
            pushWebContentView(
                webContent: sendFeedbackWebContent,
                screenAccessibility: .sendFeedback,
                backTappedFromWebContentStep: AppFlowStep.backTappedFromSendFeedback
            )
            
        case .backTappedFromSendFeedback:
            navigationController.popViewController(animated: true)
            
        case .reportABugTappedFromMenu:
            let reportABugWebContent = ReportABugWebContent(localizationServices: appDiContainer.core.dataLayer.getLocalizationServices())
            
            pushWebContentView(
                webContent: reportABugWebContent,
                screenAccessibility: .reportABug,
                backTappedFromWebContentStep: AppFlowStep.backTappedFromReportABug
            )
            
        case .backTappedFromReportABug:
            navigationController.popViewController(animated: true)
            
        case .askAQuestionTappedFromMenu:
            let askAQuestionWebContent = AskAQuestionWebContent(localizationServices: appDiContainer.core.dataLayer.getLocalizationServices())
            
            pushWebContentView(
                webContent: askAQuestionWebContent,
                screenAccessibility: .askAQuestion,
                backTappedFromWebContentStep: AppFlowStep.backTappedFromAskAQuestion
            )
            
        case .backTappedFromAskAQuestion:
            navigationController.popViewController(animated: true)
            
        case .leaveAReviewTappedFromMenu(let screenName, let siteSection, let siteSubSection, let contentLanguage, let contentLanguageSecondary):
            
            let appleAppId: String = appDiContainer.core.dataLayer.getAppConfig().getAppleAppId()
            
            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(appleAppId)?action=write-review") else {
                let error: Error = NSError.errorWithDescription(description: "Failed to open to apple review.  Invalid URL.")
                presentError(appLanguage: appLanguage, error: error)
                return
            }
            
            let linkTapped = URLLinkTappedParams(
                url: writeReviewURL,
                screenName: screenName,
                siteSection: siteSection,
                siteSubSection: siteSubSection,
                contentLanguage: contentLanguage,
                contentLanguageSecondary: contentLanguageSecondary
            )
            
            navigateToURL(linkTapped: linkTapped, appLanguage: appLanguage)
            
        case .shareAStoryWithUsTappedFromMenu:
            let shareStoryWebContent = ShareAStoryWithUsWebContent(localizationServices: appDiContainer.core.dataLayer.getLocalizationServices())
            
            pushWebContentView(
                webContent: shareStoryWebContent,
                screenAccessibility: .shareAStoryWithUs,
                backTappedFromWebContentStep: AppFlowStep.backTappedFromShareAStoryWithUs
            )
            
        case .backTappedFromShareAStoryWithUs:
            navigationController.popViewController(animated: true)
            
        case .termsOfUseTappedFromMenu:
            
            let termsOfUserWebContent = TermsOfUseWebContent(localizationServices: appDiContainer.core.dataLayer.getLocalizationServices())
            
            pushWebContentView(
                webContent: termsOfUserWebContent,
                screenAccessibility: .termsOfUse,
                backTappedFromWebContentStep: AppFlowStep.backTappedFromTermsOfUse
            )
            
        case .backTappedFromTermsOfUse:
            navigationController.popViewController(animated: true)
            
        case .privacyPolicyTappedFromMenu:
            
            let privacyPolicyWebContent = PrivacyPolicyWebContent(localizationServices: appDiContainer.core.dataLayer.getLocalizationServices())
            
            pushWebContentView(
                webContent: privacyPolicyWebContent,
                screenAccessibility: .privacyPolicy,
                backTappedFromWebContentStep: AppFlowStep.backTappedFromPrivacyPolicy
            )
            
        case .backTappedFromPrivacyPolicy:
            navigationController.popViewController(animated: true)
            
        case .copyrightInfoTappedFromMenu:
            
            let copyrightInfoWebContent = CopyrightInfoWebContent(localizationServices: appDiContainer.core.dataLayer.getLocalizationServices())
            
            pushWebContentView(
                webContent: copyrightInfoWebContent,
                screenAccessibility: .copyrightInfo,
                backTappedFromWebContentStep: AppFlowStep.backTappedFromCopyrightInfo
            )
            
        case .backTappedFromCopyrightInfo:
            navigationController.popViewController(animated: true)
            
        case .deleteAccountTappedFromMenu:
            
            presentView(
                view: getDeleteAccountView(),
                animated: true
            )
            
        case .closeTappedFromDeleteAccount:
            dismissView(animated: true)
            
        case .deleteAccountTappedFromDeleteAccount:
            
            let confirmDeleteAccountView = getConfirmDeleteAccountView()
            
            dismissView(animated: true, completion: { [weak self] in
             
                self?.presentView(
                    view: confirmDeleteAccountView,
                    animated: true
                )
            })
       
        case .deleteAccountTappedFromConfirmDeleteAccount:
            
            presentView(
                view: getDeleteAccountProgressView(),
                animated: true
            )
                                
        case .cancelTappedFromDeleteAccount:
            dismissView(animated: true)

        case .didFinishAccountDeletionWithSuccessFromDeleteAccountProgress:
            
            let localizationServices: LocalizationServicesInterface = appDiContainer.core.dataLayer.getLocalizationServices()
            let appLanguage: AppLanguageDomainModel = self.appLanguage
            
            dismissView(animated: true, completion: { [weak self] in
                
                let title: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.accountDeletedAlertTitle.key)
                let message: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.accountDeletedAlertMessage.key)
                
                self?.presentAlert(appLanguage: appLanguage, title: title, message: message)
            })
            
        case .didFinishAccountDeletionWithErrorFromDeleteAccountProgress(let error):
            
            let appLanguage: AppLanguageDomainModel = self.appLanguage
            
            dismissView(animated: true, completion: { [weak self] in
                
                self?.presentError(appLanguage: appLanguage, error: error)
            })
            
        case .copyFirebaseDeviceTokenTappedFromMenu:
            if appDiContainer.core.dataLayer.getAppConfig().isDebug {
                copyFirebaseDeviceTokenToClipboard()
            }
            
        default:
            break
        }
    }
}

// MARK: - Share GodTools

extension MenuFlow {
    
    private func getShareGodToolsView() -> UIViewController {

        let viewModel = ShareGodToolsViewModel(
            stepEmitter: stepEmitter,
            appLanguage: appLanguage,
            getShareGodToolsStringsUseCase: appDiContainer.feature.shareGodTools.domainLayer.getShareGodToolsStringsUseCase()
        )
        
        let view = ShareGodToolsView(viewModel: viewModel)
        
        return view
    }
}

// MARK: - Menu

extension MenuFlow {
    
    private func getMenuView(appLanguage: AppLanguageDomainModel) -> UIViewController {
            
        let viewModel = MenuViewModel(
            stepEmitter: stepEmitter,
            appLanguage: appLanguage,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getMenuStringsUseCase: appDiContainer.feature.menu.domainLayer.getMenuStringsUseCase(),
            getTutorialIsAvailableUseCase: appDiContainer.feature.tutorial.domainLayer.getTutorialIsAvailableUseCase(),
            disableOptInOnboardingBannerUseCase: appDiContainer.feature.tools.domainLayer.getDisableOptInOnboardingBannerUseCase(),
            getAccountCreationIsSupportedUseCase: appDiContainer.feature.account.domainLayer.getAccountCreationIsSupportedUseCase(),
            getUserIsAuthenticatedUseCase: appDiContainer.feature.account.domainLayer.getUserIsAuthenticatedUseCase(),
            logOutUserUseCase: appDiContainer.feature.account.domainLayer.getLogOutUserUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase(),
            appConfig: appDiContainer.core.dataLayer.getAppConfig()
        )
        
        let view = MenuView(viewModel: viewModel)
        
        let doneButton = AppInterfaceStringBarItem(
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            localizationServices: appDiContainer.core.dataLayer.getLocalizationServices(),
            localizedStringKey: "done",
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
}

// MARK: - Social SignIn

extension MenuFlow {
    
    private func getSocialSignInView(authenticationType: SocialSignInAuthenticationType) -> UIViewController {
        
        let viewBackgroundColor: Color = ColorPalette.gtBlue.color
        let viewBackgroundUIColor: UIColor = UIColor(viewBackgroundColor)
        
        let viewModel = SocialSignInViewModel(
            stepEmitter: stepEmitter,
            presentAuthViewController: navigationController,
            authenticationType: authenticationType,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getSocialCreateAccountStringsUseCase: appDiContainer.feature.account.domainLayer.getSocialCreateAccountStringsUseCase(),
            getSocialSignInStringsUseCase: appDiContainer.feature.account.domainLayer.getSocialSignInStringsUseCase(),
            authenticateUserUseCase: appDiContainer.feature.account.domainLayer.getAuthenticateUserUseCase()
        )
        
        let screenAccessibility: AccessibilityStrings.Screen
        
        switch authenticationType {
        case .createAccount:
            screenAccessibility = .createAccount
        case .login:
            screenAccessibility = .login
        }
        
        let view = SocialSignInView(
            viewModel: viewModel,
            backgroundColor: viewBackgroundColor,
            screenAccessibility: screenAccessibility
        )
        
        let closeButton = AppCloseBarItem(
            color: .white,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
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
}

// MARK: - Social Auth Error

extension MenuFlow {
    
    private func presentSocialAuthError(authError: AuthErrorDomainModel) {
            
        let errorIsUserCancelled: Bool = authError.getError()?.code == NSUserCancelledError
        
        guard !errorIsUserCancelled else {
            return
        }

        presentAlertMessage(appLanguage: appLanguage, alertMessage: self.getAuthErrorAlertMessage(authError: authError))
    }
    
    private func getAuthErrorAlertMessage(authError: AuthErrorDomainModel) -> AlertMessage {
        
        let localizationServices: LocalizationServicesInterface = appDiContainer.core.dataLayer.getLocalizationServices()
        let appLanguageLocaleId = appLanguage.localeId
        
        let message: String
        
        switch authError {
        case .accountAlreadyExists:
            message = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: "authError.userAccountAlreadyExists.message")
            
        case .accountNotFound:
            message = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageLocaleId, key: "authError.userAccountNotFound.message")
            
        case .other(let error):
            message = error.localizedDescription
        }
        
        return AlertMessage(
            title: "",
            message: message
        )
    }
}

// MARK: - Account

extension MenuFlow {
 
    private func getAccountView() -> UIViewController {
        
        let viewModel = AccountViewModel(
            stepEmitter: stepEmitter,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getUserAccountDetailsUseCase: appDiContainer.feature.account.domainLayer.getUserAccountDetailsUseCase(),
            getUserActivityUseCase: appDiContainer.feature.userActivity.domainLayer.getUserActivityUseCase(),
            getGlobalActivityThisWeekUseCase: appDiContainer.feature.globalActivity.domainLayer.getGlobalActivityThisWeekUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            getAccountStringsUseCase: appDiContainer.feature.account.domainLayer.getAccountStringsUseCase(),
            getGlobalActivityEnabledUseCase: appDiContainer.feature.globalActivity.domainLayer.getGlobalActivityEnabledUseCase(),
            didPullToRefreshAccountUseCase: appDiContainer.feature.account.domainLayer.getDidPullToRefreshAccountUseCase()
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
}

// MARK: - Delete Account

extension MenuFlow {
    
    private func getDeleteAccountView() -> UIViewController {
        
        let viewBackgroundColor: Color = Color.white
        let viewBackgroundUIColor: UIColor = UIColor(viewBackgroundColor)
        
        let viewModel = DeleteAccountViewModel(
            stepEmitter: stepEmitter,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getDeleteAccountStringsUseCase: appDiContainer.feature.account.domainLayer.getDeleteAccountStringsUseCase()
        )
        
        let view = DeleteAccountView(viewModel: viewModel, backgroundColor: viewBackgroundColor)
        
        let closeButton = AppCloseBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
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
        
        let localizationServices: LocalizationServicesInterface = appDiContainer.core.dataLayer.getLocalizationServices()
        
        let viewController = UIAlertController(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.confirmDeleteAccountTitle.key),
            message: "",
            preferredStyle: .actionSheet
        )
        
        viewController.addAction(
            UIAlertAction(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.confirmDeleteAccountConfirmButtonTitle.key),
                style: .destructive,
                handler: { [weak self] (action: UIAlertAction) in
                    
                    self?.navigate(step: AppFlowStep.deleteAccountTappedFromConfirmDeleteAccount)
                }
            )
        )
        
        viewController.addAction(
            UIAlertAction(
                title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.cancel.key),
                style: .cancel,
                handler: { (action: UIAlertAction) in
                }
            )
        )
        
        return viewController
    }
    
    private func getDeleteAccountProgressView() -> UIViewController {
        
        let viewBackgroundColor: Color = Color.white
        let viewBackgroundUIColor: UIColor = UIColor(viewBackgroundColor)
        
        let viewModel = DeleteAccountProgressViewModel(
            stepEmitter: stepEmitter,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getDeleteAccountProgressStringsUseCase: appDiContainer.feature.account.domainLayer.getDeleteAccountProgressStringsUseCase(),
            deleteAccountUseCase: appDiContainer.feature.account.domainLayer.getDeleteAccountUseCase()
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
}

// MARK: - Web Content

extension MenuFlow {
    
    private func getWebContentView(webContent: WebContentType, screenAccessibility: AccessibilityStrings.Screen?, backTappedFromWebContentStep: AppFlowStep) -> UIViewController {
        
        let viewModel = WebContentViewModel(
            stepEmitter: stepEmitter,
            webContent: webContent,
            backTappedFromWebContentStep: backTappedFromWebContentStep,
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase()
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
            ),
            screenAccessibility: screenAccessibility
        )
        
        return view
    }
    
    private func pushWebContentView(webContent: WebContentType, screenAccessibility: AccessibilityStrings.Screen?, backTappedFromWebContentStep: AppFlowStep) {

        let view = getWebContentView(
            webContent: webContent,
            screenAccessibility: screenAccessibility,
            backTappedFromWebContentStep: backTappedFromWebContentStep
        )

        navigationController.pushViewController(view, animated: true)
    }
}

// MARK: - Copy Firebase Device Token

extension MenuFlow {
    
    private func copyFirebaseDeviceTokenToClipboard() {
        
        appDiContainer.core.dataLayer.getSharedFirebaseMessaging()
            .getDeviceTokenPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.presentFirebaseDeviceTokenCopyError(error: error)
                }
                
            } receiveValue: { [weak self] (token: String) in
                
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = token
                
                self?.presentFirebaseDeviceTokenCopied(token: token)
            }
            .store(in: &cancellables)
    }
    
    private func presentFirebaseDeviceTokenCopied(token: String) {
        
        let view = AlertMessageView(
            title: "Device Token Copied To Clipboard",
            message: "Token String: \(token)",
            acceptTitle: "OK",
            cancelTitle: nil,
            acceptTapped: nil,
            cancelTapped: nil
        )
        
        presentView(view: view.controller, animated: true)
    }
    
    private func presentFirebaseDeviceTokenCopyError(error: Error) {
        presentError(appLanguage: LanguageCodeDomainModel.english.rawValue, error: error)
    }
}
