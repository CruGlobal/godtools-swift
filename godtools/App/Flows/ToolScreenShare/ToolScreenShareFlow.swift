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
    
    private let toolData: ToolSettingsFlowToolData
    private let primaryLanguage: LanguageDomainModel
    private let parallelLanguage: LanguageDomainModel?
    
    private var toolScreenShareTutorialModal: UIViewController?
    private var creatingToolScreenShareSessionModal: UIViewController?
    private var cancellables: Set<AnyCancellable> = Set()
    
    // NOTE: I need to keep these stored in the Flow since we use UIAlertController for the TimedOut alert and Share Modal which must set the title and message when allocating those views. ~Levi
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var creatingToolScreenShareSessionTimedOutDomainModel: CreatingToolScreenShareSessionTimedOutDomainModel?
    @Published private var shareToolScreenShareSessionDomainModel: ShareToolScreenShareSessionDomainModel?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, toolData: ToolSettingsFlowToolData, primaryLanguage: LanguageDomainModel, parallelLanguage: LanguageDomainModel?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolData = toolData
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage
        
        let getToolScreenShareTutorialHasBeenViewedUseCase: GetToolScreenShareTutorialHasBeenViewedUseCase = appDiContainer.feature.toolScreenShare.domainLayer.getToolScreenShareTutorialHasBeenViewedUseCase()
        
        getToolScreenShareTutorialHasBeenViewedUseCase
            .getViewedPublisher(tool: toolData.renderer.value.resource)
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] (toolScreenShareTutorialViewed: ToolScreenShareTutorialViewedDomainModel) in
                self?.navigateToInitialView(toolScreenShareTutorialViewed: toolScreenShareTutorialViewed)
            }
            .store(in: &cancellables)
        
        appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        appDiContainer.feature.toolScreenShare.domainLayer.getViewCreatingToolScreenShareSessionTimedOutUseCase()
            .viewPublisher(appLanguage: appLanguage)
            .sink { [weak self] (domainModel: CreatingToolScreenShareSessionTimedOutDomainModel) in
                self?.creatingToolScreenShareSessionTimedOutDomainModel = domainModel
            }
            .store(in: &cancellables)
        
        appDiContainer.feature.toolScreenShare.domainLayer.getViewShareToolScreenShareSessionUseCase()
            .viewPublisher(appLanguage: appLanguage)
            .sink { [weak self] (domainModel: ShareToolScreenShareSessionDomainModel) in
                self?.shareToolScreenShareSessionDomainModel = domainModel
            }
            .store(in: &cancellables)
    }
    
    private func navigateToInitialView(toolScreenShareTutorialViewed: ToolScreenShareTutorialViewedDomainModel) {
        
         let toolScreenShareTutorialHasBeenViewed: Bool = toolScreenShareTutorialViewed.hasBeenViewed
         
         if toolData.tractRemoteSharePublisher.webSocketIsConnected, let channel = toolData.tractRemoteSharePublisher.tractRemoteShareChannel {
         
             navigate(step: .didCreateSessionFromCreatingToolScreenShareSession(result: .success(channel)))
         }
         else if toolScreenShareTutorialHasBeenViewed || (toolData.tractRemoteSharePublisher.webSocketIsConnected && toolData.tractRemoteSharePublisher.tractRemoteShareChannel != nil) {
         
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
            
        case .shareLinkTappedFromToolScreenShareTutorial:
           
            dismissToolScreenShareTutorial()
            presentCreatingToolScreenShareSession()
            
        case .closeTappedFromCreatingToolScreenShareSession:
            
            dismissCreatingToolScreenShareSession()
            
        case .didCreateSessionFromCreatingToolScreenShareSession(let result):
            
            dismissCreatingToolScreenShareSession()
            
            // TODO: Implement back in. ~Levi
            //flowDelegate?.navigate(step: .toolSettingsFlowCompleted)
            
            switch result {
                
            case .success(let channel):
                
                let tractRemoteShareURLBuilder: TractRemoteShareURLBuilder = appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteShareURLBuilder()
                
                let resource: ResourceModel = toolData.renderer.value.resource
                
                guard let domainModel = shareToolScreenShareSessionDomainModel,
                      let remoteShareUrl = tractRemoteShareURLBuilder.buildRemoteShareURL(resource: resource, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, subscriberChannelId: channel.subscriberChannelId) else {
                    
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
        
        let toolScreenShareTutorialView = getToolScreenShareTutorialView(tool: toolData.renderer.value.resource)
        
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
    
    // TODO: Eventually this will need to be ToolDomainModel. ~Levi
    private func getToolScreenShareTutorialView(tool: ResourceModel) -> UIViewController {
        
        let viewModel = ToolScreenShareTutorialViewModel(
            flowDelegate: self,
            tool: tool,
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
            toggleVisibilityPublisher: viewModel.$hidesSkipButton.eraseToAnyPublisher()
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
            resourceId: toolData.renderer.value.resource.id,
            getCurrentAppLanguage: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewCreatingToolScreenShareSessionUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getViewCreatingToolScreenShareSessionUseCase(),
            tractRemoteSharePublisher: toolData.tractRemoteSharePublisher,
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
        
        let shareMessage: String = String.localizedStringWithFormat(
            interfaceStrings.shareMessage,
            shareUrl
        )
        
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
