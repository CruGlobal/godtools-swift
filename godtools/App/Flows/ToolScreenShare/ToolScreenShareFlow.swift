//
//  ToolScreenShareFlow.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class ToolScreenShareFlow: Flow {
    
    typealias ToolScreenShareSettingsObserver = ToolSettingsObserver & RemoteShareable
    
    private let toolSettingsObserver: ToolScreenShareSettingsObserver
    
    private var toolScreenShareTutorialModal: UIViewController?
    private var creatingToolScreenShareSessionModal: UIViewController?
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var creatingToolScreenShareSessionTimedOutStringsDomainModel: CreatingToolScreenShareSessionTimedOutStringsDomainModel?
    @Published private var shareToolScreenShareSessionStringsDomainModel: ShareToolScreenShareSessionStringsDomainModel?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, toolSettingsObserver: ToolScreenShareSettingsObserver) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolSettingsObserver = toolSettingsObserver
        
        let getToolScreenShareTutorialHasBeenViewedUseCase: GetToolScreenShareTutorialHasBeenViewedUseCase = appDiContainer.feature.toolScreenShare.domainLayer.getToolScreenShareTutorialHasBeenViewedUseCase()
        
        getToolScreenShareTutorialHasBeenViewedUseCase
            .execute(toolId: toolSettingsObserver.toolId)
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] (toolScreenShareTutorialViewed: ToolScreenShareTutorialViewedDomainModel) in
                self?.navigateToInitialView(toolScreenShareTutorialViewed: toolScreenShareTutorialViewed)
            }
            .store(in: &cancellables)
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        let getCreatingToolScreenShareSessionTimedOutStringsUseCase: GetCreatingToolScreenShareSessionTimedOutStringsUseCase = appDiContainer.feature.toolScreenShare.domainLayer
            .getCreatingToolScreenShareSessionTimedOutStringsUseCase()
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getCreatingToolScreenShareSessionTimedOutStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: CreatingToolScreenShareSessionTimedOutStringsDomainModel) in
                self?.creatingToolScreenShareSessionTimedOutStringsDomainModel = domainModel
            }
            .store(in: &cancellables)
        
        let getShareToolScreenShareSessionStringsUseCase: GetShareToolScreenShareSessionStringsUseCase = appDiContainer.feature.toolScreenShare.domainLayer
            .getShareToolScreenShareSessionStringsUseCase()
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getShareToolScreenShareSessionStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ShareToolScreenShareSessionStringsDomainModel) in
                self?.shareToolScreenShareSessionStringsDomainModel = strings
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func navigateToInitialView(toolScreenShareTutorialViewed: ToolScreenShareTutorialViewedDomainModel) {
        
        let toolScreenShareTutorialHasBeenViewed: Bool = toolScreenShareTutorialViewed.hasBeenViewed
        
        if toolScreenShareTutorialHasBeenViewed || toolSettingsObserver.tractRemoteSharePublisher.webSocketIsConnected {
                        
            presentToolScreenShareTutorial(showTutorialPages: .lastPageWithQRCodeOption)
        }
        else {
            
            presentToolScreenShareTutorial()
        }
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .closeTappedFromToolScreenShareTutorial:
            dismissToolScreenShareTutorial(animated: true) {
                
            }
            
        case .generateQRCodeTappedFromToolScreenShareTutorial:
            dismissToolScreenShareTutorial(animated: true) { [weak self] in
                self?.presentCreatingToolScreenShareSession(createSessionTrigger: .generateQRCodeTappedFromScreenShareTutorial)
            }
            
            
        case .shareLinkTappedFromToolScreenShareTutorial:
            dismissToolScreenShareTutorial(animated: true) { [weak self] in
                self?.presentCreatingToolScreenShareSession(createSessionTrigger: .shareLinkTappedFromScreenShareTutorial)
            }
            
        case .closeTappedFromCreatingToolScreenShareSession:
            dismissCreatingToolScreenShareSession()
            
        case .shareQRCodeTappedFromToolScreenShareSession(let shareUrl):
            presentQRCodeView(shareUrl: shareUrl)
            
        case .dismissedShareToolScreenShareActivityViewController:
            completeFlow(state: .userClosedShareModal)
            
        case .closeTappedFromShareToolScreenQRCode:
            navigationController.dismiss(animated: true)
            completeFlow(state: .userSharedQRCode)
            
        case .didCreateSessionFromCreatingToolScreenShareSession(let result, let createSessionTrigger):
            
            dismissCreatingToolScreenShareSession()
                                    
            switch result {
                
            case .success(let channel):
                
                let tractRemoteShareURLBuilder: TractRemoteShareURLBuilder = appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteShareURLBuilder()
                                
                guard let strings = shareToolScreenShareSessionStringsDomainModel, let remoteShareUrl = tractRemoteShareURLBuilder.buildRemoteShareURL(toolId: toolSettingsObserver.toolId, primaryLanguageId: toolSettingsObserver.languages.primaryLanguageId, parallelLanguageId: toolSettingsObserver.languages.parallelLanguageId, selectedLanguageId: toolSettingsObserver.languages.selectedLanguageId, page: toolSettingsObserver.pageNumber, subscriberChannelId: channel.id) else {
                    
                    let viewModel = AlertMessageViewModel(
                        title: "Error",
                        message: "Failed to create remote share url.",
                        cancelTitle: nil,
                        acceptTitle: "OK"
                    )
                    let view = AlertMessageView(viewModel: viewModel)
                    
                    navigationController.present(view.controller, animated: true, completion: nil)
                    
                    return
                }
                                
                switch createSessionTrigger {
                    
                case .generateQRCodeTappedFromScreenShareTutorial:
                    presentQRCodeView(shareUrl: remoteShareUrl)
                    
                case .shareLinkTappedFromScreenShareTutorial:
                    presentShareToolScreenShareSessionView(
                        strings: strings,
                        shareUrl: remoteShareUrl
                    )
                }
                
            case .failure(let error):
                                
                switch error {
                
                case .timedOut:
                   
                    guard let strings = creatingToolScreenShareSessionTimedOutStringsDomainModel else {
                        return
                    }

                    navigationController.present(
                        getCreatingToolScreenShareSessionTimedOutView(strings: strings),
                        animated: true,
                        completion: nil
                    )
                }
            }
            
        case .cancelTappedFromCreateToolScreenShareSessionTimeout:
            completeFlow(state: .failedToCreateSession)
            
        case .acceptTappedFromCreateToolScreenShareSessionTimeout:
            completeFlow(state: .failedToCreateSession)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: ToolScreenShareFlowCompletedState) {
        flowDelegate?.navigate(step: .toolScreenShareFlowCompleted(state: state))
    }
    
    private func presentCreatingToolScreenShareSession(createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger) {
        
        let tractRemoteSharePublisher: TractRemoteSharePublisher = toolSettingsObserver.tractRemoteSharePublisher
        
        if tractRemoteSharePublisher.webSocketIsConnected, let channel = tractRemoteSharePublisher.tractRemoteShareChannel {
            navigate(step: .didCreateSessionFromCreatingToolScreenShareSession(result: .success(channel), createSessionTrigger: createSessionTrigger))
            return
        }
        
        guard creatingToolScreenShareSessionModal == nil else {
            return
        }
        
        let creatingToolScreenShareSessionView = getCreatingToolScreenShareSessionView(
            createSessionTrigger: createSessionTrigger
        )
        
        let modal = ModalNavigationController.defaultModal(
            rootView: creatingToolScreenShareSessionView,
            statusBarStyle: .default
        )
        
        navigationController.present(modal, animated: true, completion: nil)
        
        creatingToolScreenShareSessionModal = modal
    }
    
    private func dismissCreatingToolScreenShareSession() {
        
        guard let modal = creatingToolScreenShareSessionModal else {
            return
        }
        
        modal.dismiss(animated: true)
        creatingToolScreenShareSessionModal = nil
    }
    
    private func presentShareToolScreenShareSessionView(strings: ShareToolScreenShareSessionStringsDomainModel, shareUrl: String) {
        
        let view = getShareToolScreenShareSessionView(
            strings: strings,
            shareUrl: shareUrl
        )
        
        navigationController.present(view, animated: true, completion: nil)
    }
    
    private func presentQRCodeView(shareUrl: String) {
        
        let qrCodeView = getToolScreenShareQRCodeView(shareUrl: shareUrl)
        
        navigationController.present(qrCodeView, animated: true)
    }
}

// MARK: - Tool Screen Share Tutorial View

extension ToolScreenShareFlow {
    
    private func presentToolScreenShareTutorial(showTutorialPages: ShowToolScreenShareTutorialPages = .allPages) {
        
        guard toolScreenShareTutorialModal == nil else {
            return
        }
        
        let toolScreenShareTutorialView = getToolScreenShareTutorialView(
            toolId: toolSettingsObserver.toolId,
            showTutorialPages: showTutorialPages
        )
        
        let modal = ModalNavigationController.defaultModal(
            rootView: toolScreenShareTutorialView,
            statusBarStyle: .default
        )
        
        navigationController.present(
            modal,
            animated: true,
            completion: nil
        )
        
        toolScreenShareTutorialModal = modal
    }
    
    private func dismissToolScreenShareTutorial(animated: Bool, completion: (() -> Void)?) {
        
        guard let modal = self.toolScreenShareTutorialModal else {
            completion?()
            return
        }
        
        if animated {
            modal.dismiss(animated: true, completion: completion)
        }
        else {
            modal.dismiss(animated: false)
            completion?()
        }
        
        toolScreenShareTutorialModal = nil
    }
    
    private func getToolScreenShareTutorialView(toolId: String, showTutorialPages: ShowToolScreenShareTutorialPages) -> UIViewController {
        
        let viewModel = ToolScreenShareTutorialViewModel(
            flowDelegate: self,
            toolId: toolId,
            showTutorialPages: showTutorialPages,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolScreenShareTutorialStringsUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getToolScreenShareTutorialStringsUseCase(),
            getToolScreenShareTutorialUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getToolScreenShareTutorialUseCase(),
            didViewToolScreenShareTutorialUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getDidViewToolScreenShareTutorialUseCase()
        )
        
        let view = ToolScreenShareTutorialView(viewModel: viewModel)
        
        let closeButton = AppCloseBarItem(
            color: ColorPalette.gtBlue.uiColor,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
        )
        
        let skipButton = AppSkipBarItem(
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            target: viewModel,
            action: #selector(viewModel.skipTapped),
            accessibilityIdentifier: AccessibilityStrings.Button.skip.id,
            hidesBarItemPublisher: viewModel.$hidesSkipButton.eraseToAnyPublisher()
        )
        
        let navigationBar = AppNavigationBar(
            appearance: nil,
            backButton: nil,
            leadingItems: [closeButton],
            trailingItems: [skipButton]
        )
        
        let hostingView = AppHostingController<ToolScreenShareTutorialView>(
            rootView: view,
            navigationBar: navigationBar
        )
        
        return hostingView
    }
}

// MARK: - Create Tool Screen Share Session View

extension ToolScreenShareFlow {
    
    private func getCreatingToolScreenShareSessionView(createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger) -> UIViewController {
        
        let viewModel = CreatingToolScreenShareSessionViewModel(
            flowDelegate: self,
            toolId: toolSettingsObserver.toolId,
            createSessionTrigger: createSessionTrigger,
            getCurrentAppLanguage: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getCreatingToolScreenShareSessionStringsUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getCreatingToolScreenShareSessionStringsUseCase(),
            tractRemoteSharePublisher: toolSettingsObserver.tractRemoteSharePublisher,
            incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase()
        )
        
        let view = CreatingToolScreenShareSessionView(
            viewModel: viewModel
        )
        
        let closeButton = AppCloseBarItem(
            color: ColorPalette.gtBlue.uiColor,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
        )
        
        let navigationBar = AppNavigationBar(
            appearance: nil,
            backButton: nil,
            leadingItems: [],
            trailingItems: [closeButton]
        )
        
        let hostingView = AppHostingController<CreatingToolScreenShareSessionView>(
            rootView: view,
            navigationBar: navigationBar
        )
        
        return hostingView
    }
}

// MARK: - Create Screen Share Session Timed Out View

extension ToolScreenShareFlow {
    
    private func getCreatingToolScreenShareSessionTimedOutView(strings: CreatingToolScreenShareSessionTimedOutStringsDomainModel) -> UIViewController {
        
        let viewModel = CreatingToolScreenShareSessionTimedOutViewModel(
            flowDelegate: self,
            strings: strings
        )
        
        let view = CreatingToolScreenShareSessionTimedOutView(viewModel: viewModel)
        
        return view.controller
    }
}

// MARK: - Share Tool Screen Share Session View

extension ToolScreenShareFlow {
    
    private func getShareToolScreenShareSessionView(strings: ShareToolScreenShareSessionStringsDomainModel, shareUrl: String) -> UIViewController {
                
        let shareMessage: String = String.localizedStringWithFormat(strings.shareMessage, shareUrl)

        let viewModel = ShareToolScreenShareSessionViewModel(
            flowDelegate: self,
            strings: strings,
            shareMessage: shareMessage,
            shareUrl: shareUrl,
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = ShareToolScreenShareSessionView(
            viewModel: viewModel
        )
        
        return view.controller
    }
}

// MARK: - Tool Screen Share QR Code View

extension ToolScreenShareFlow {
    
    private func getToolScreenShareQRCodeView(shareUrl: String) -> UIViewController {
        
        let viewModel = ToolScreenShareQRCodeViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolScreenShareQRCodeStringsUseCase: appDiContainer.feature.toolScreenShareQRCode.domainLayer.getToolScreenShareQRCodeStringsUseCase(),
            shareUrl: shareUrl
        )
        
        let view = ToolScreenShareQRCodeView(viewModel: viewModel)
        
        let hostingView = AppHostingController<ToolScreenShareQRCodeView>(
            rootView: view,
            navigationBar: nil,
            animateInAnimatedTransitioning: NoAnimationTransition(transition: .transitionIn),
            animateOutAnimatedTransitioning: NoAnimationTransition(transition: .transitionOut)
        )

        let overlayNavigationController = OverlayNavigationController(
            rootView: hostingView,
            hidesNavigationBar: true,
            navigationBarAppearance: nil
        )
        
        return overlayNavigationController
    }
}
