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

    private let toolSettingsObserver: ToolSettingsObserver
    
    private var toolScreenShareTutorialModal: UIViewController?
    private var creatingToolScreenShareSessionModal: UIViewController?
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var creatingToolScreenShareSessionTimedOutDomainModel: CreatingToolScreenShareSessionTimedOutDomainModel?
    @Published private var shareToolScreenShareSessionDomainModel: ShareToolScreenShareSessionDomainModel?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, toolSettingsObserver: ToolSettingsObserver) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolSettingsObserver = toolSettingsObserver
        
        let getToolScreenShareTutorialHasBeenViewedUseCase: GetToolScreenShareTutorialHasBeenViewedUseCase = appDiContainer.feature.toolScreenShare.domainLayer.getToolScreenShareTutorialHasBeenViewedUseCase()
        
        getToolScreenShareTutorialHasBeenViewedUseCase
            .getViewedPublisher(toolId: toolSettingsObserver.toolId)
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] (toolScreenShareTutorialViewed: ToolScreenShareTutorialViewedDomainModel) in
                self?.navigateToInitialView(toolScreenShareTutorialViewed: toolScreenShareTutorialViewed)
            }
            .store(in: &cancellables)
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        let viewCreatingToolScreenShareSessionTimedOutUseCase: ViewCreatingToolScreenShareSessionTimedOutUseCase = appDiContainer.feature.toolScreenShare.domainLayer
            .getViewCreatingToolScreenShareSessionTimedOutUseCase()
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                viewCreatingToolScreenShareSessionTimedOutUseCase
                    .viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: CreatingToolScreenShareSessionTimedOutDomainModel) in
                self?.creatingToolScreenShareSessionTimedOutDomainModel = domainModel
            }
            .store(in: &cancellables)
        
        let viewShareToolScreenShareSessionUseCase: ViewShareToolScreenShareSessionUseCase = appDiContainer.feature.toolScreenShare.domainLayer
            .getViewShareToolScreenShareSessionUseCase()
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                viewShareToolScreenShareSessionUseCase
                    .viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ShareToolScreenShareSessionDomainModel) in
                self?.shareToolScreenShareSessionDomainModel = domainModel
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func navigateToInitialView(toolScreenShareTutorialViewed: ToolScreenShareTutorialViewedDomainModel) {
        
        let toolScreenShareTutorialHasBeenViewed: Bool = toolScreenShareTutorialViewed.hasBeenViewed
        let tractRemoteSharePublisher: TractRemoteSharePublisher = toolSettingsObserver.tractRemoteSharePublisher
        
        if tractRemoteSharePublisher.webSocketIsConnected, let channel = tractRemoteSharePublisher.tractRemoteShareChannel {
            navigate(step: .didCreateSessionFromCreatingToolScreenShareSession(result: .success(channel)))
        }
        else if toolScreenShareTutorialHasBeenViewed || (tractRemoteSharePublisher.webSocketIsConnected && tractRemoteSharePublisher.tractRemoteShareChannel != nil) {
            presentCreatingToolScreenShareSession()
        }
        else {
            presentToolScreenShareTutorial()
        }
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .closeTappedFromToolScreenShareTutorial:
            dismissToolScreenShareTutorial()
            
        case .skipTappedFromToolScreenShareTutorial:
            
            dismissToolScreenShareTutorial()
            presentCreatingToolScreenShareSession()
            
        case .shareLinkTappedFromToolScreenShareTutorial:
           
            dismissToolScreenShareTutorial()
            presentCreatingToolScreenShareSession()
            
        case .closeTappedFromCreatingToolScreenShareSession:
            
            dismissCreatingToolScreenShareSession()
            
        case .didCreateSessionFromCreatingToolScreenShareSession(let result):
            
            dismissCreatingToolScreenShareSession()
            
            flowDelegate?.navigate(step: .toolScreenShareFlowCompleted(state: .didLoadToolScreenShareRemoteSession))
                        
            switch result {
                
            case .success(let channel):
                
                let tractRemoteShareURLBuilder: TractRemoteShareURLBuilder = appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteShareURLBuilder()
                                
                guard let domainModel = shareToolScreenShareSessionDomainModel,
                      let remoteShareUrl = tractRemoteShareURLBuilder.buildRemoteShareURL(toolId: toolSettingsObserver.toolId, primaryLanguageId: toolSettingsObserver.languages.primaryLanguageId, parallelLanguageId: toolSettingsObserver.languages.parallelLanguageId, selectedLanguageId: toolSettingsObserver.languages.selectedLanguageId, page: toolSettingsObserver.pageNumber, subscriberChannelId: channel.subscriberChannelId) else {
                    
                    let viewModel = AlertMessageViewModel(
                        title: "Error",
                        message: "Failed to create remote share url.",
                        cancelTitle: nil,
                        acceptTitle: "OK",
                        acceptHandler: nil
                    )
                    let view = AlertMessageView(viewModel: viewModel)
                    
                    navigationController.present(view.controller, animated: true, completion: nil)
                    
                    return
                }
                
                let view = getShareToolScreenShareSessionView(domainModel: domainModel, shareUrl: remoteShareUrl)
                
                navigationController.present(view, animated: true, completion: nil)
                
            case .failure(let error):
                
                switch error {
                
                case .timedOut:
                   
                    guard let domainModel = creatingToolScreenShareSessionTimedOutDomainModel else {
                        return
                    }

                    navigationController.present(
                        getCreatingToolScreenShareSessionTimedOutView(domainModel: domainModel),
                        animated: true,
                        completion: nil
                    )
                }
            }
            
        default:
            break
        }
    }
    
    private func presentToolScreenShareTutorial() {
        
        guard toolScreenShareTutorialModal == nil else {
            return
        }
        
        let toolScreenShareTutorialView = getToolScreenShareTutorialView(toolId: toolSettingsObserver.toolId)
        
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
    
    private func dismissToolScreenShareTutorial() {
        
        guard let modal = self.toolScreenShareTutorialModal else {
            return
        }
        
        modal.dismiss(animated: true)
        toolScreenShareTutorialModal = nil
    }
    
    private func presentCreatingToolScreenShareSession() {
        
        guard creatingToolScreenShareSessionModal == nil else {
            return
        }
        
        let creatingToolScreenShareSessionView = getCreatingToolScreenShareSessionView()
        
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
}

extension ToolScreenShareFlow {
    
    private func getToolScreenShareTutorialView(toolId: String) -> UIViewController {
        
        let viewModel = ToolScreenShareTutorialViewModel(
            flowDelegate: self,
            toolId: toolId,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewToolScreenShareTutorialUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getViewToolScreenShareTutorialUseCase(),
            didViewToolScreenShareTutorialUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getDidViewToolScreenShareTutorialUseCase()
        )
        
        let view = ToolScreenShareTutorialView(viewModel: viewModel)
        
        let closeButton = AppCloseBarItem(
            color: ColorPalette.gtBlue.uiColor,
            target: viewModel,
            action: #selector(viewModel.closeTapped),
            accessibilityIdentifier: nil
        )
        
        let skipButton = AppSkipBarItem(
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            target: viewModel,
            action: #selector(viewModel.skipTapped),
            accessibilityIdentifier: nil,
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
    
    private func getCreatingToolScreenShareSessionView() -> UIViewController {
        
        let viewModel = CreatingToolScreenShareSessionViewModel(
            flowDelegate: self,
            toolId: toolSettingsObserver.toolId,
            getCurrentAppLanguage: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewCreatingToolScreenShareSessionUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getViewCreatingToolScreenShareSessionUseCase(),
            tractRemoteSharePublisher: toolSettingsObserver.tractRemoteSharePublisher,
            incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase()
        )
        
        let view = CreatingToolScreenShareSessionView(
            viewModel: viewModel
        )
        
        let closeButton = AppCloseBarItem(
            color: ColorPalette.gtBlue.uiColor,
            target: viewModel,
            action: #selector(viewModel.closeTapped),
            accessibilityIdentifier: nil
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
    
    private func getCreatingToolScreenShareSessionTimedOutView(domainModel: CreatingToolScreenShareSessionTimedOutDomainModel) -> UIViewController {
        
        let viewModel = CreatingToolScreenShareSessionTimedOutViewModel(
            domainModel: domainModel
        )
        
        let view = CreatingToolScreenShareSessionTimedOutView(viewModel: viewModel)
        
        return view.controller
    }
    
    private func getShareToolScreenShareSessionView(domainModel: ShareToolScreenShareSessionDomainModel, shareUrl: String) -> UIViewController {
        
        let interfaceStrings: ShareToolScreenShareSessionInterfaceStringsDomainModel = domainModel.interfaceStrings
        
        let shareMessage: String = String.localizedStringWithFormat(interfaceStrings.shareMessage, shareUrl)

        let viewModel = ShareToolScreenShareSessionViewModel(
            shareMessage: shareMessage,
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = ShareToolScreenShareSessionView(
            viewModel: viewModel
        )
        
        return view.controller
    }
}
