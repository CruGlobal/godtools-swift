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
    
    private var toolScreenShareTutorialModal: UIViewController?
    private var creatingToolScreenShareSessionModal: UIViewController?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, toolData: ToolSettingsFlowToolData) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolData = toolData
        
        let getToolScreenShareTutorialHasBeenViewedUseCase: GetToolScreenShareTutorialHasBeenViewedUseCase = appDiContainer.feature.toolScreenShare.domainLayer.getToolScreenShareTutorialHasBeenViewedUseCase()
        
        getToolScreenShareTutorialHasBeenViewedUseCase
            .getViewedPublisher(tool: toolData.renderer.value.resource)
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] (toolScreenShareTutorialViewed: ToolScreenShareViewedDomainModel) in
                self?.navigateToInitialView(toolScreenShareTutorialViewed: toolScreenShareTutorialViewed)
            }
            .store(in: &cancellables)
    }
    
    private func navigateToInitialView(toolScreenShareTutorialViewed: ToolScreenShareViewedDomainModel) {
        
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
                
                let tractRemoteShareURLBuilder: TractRemoteShareURLBuilder = appDiContainer.dataLayer.getTractRemoteShareURLBuilder()
                
                let resource: ResourceModel = toolData.renderer.value.resource
                let primaryLanguage: LanguageDomainModel = settingsPrimaryLanguage.value
                let parallelLanguage: LanguageDomainModel? = settingsParallelLanguage.value
                
                guard let remoteShareUrl = tractRemoteShareURLBuilder.buildRemoteShareURL(resource: resource, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, subscriberChannelId: channel.subscriberChannelId) else {
                    
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
                
                let viewModel = ShareToolRemoteSessionURLViewModel(
                    toolRemoteShareUrl: remoteShareUrl,
                    localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
                    trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
                )
                let view = ShareToolRemoteSessionURLView(viewModel: viewModel)
                
                navigationController.present(view.controller, animated: true, completion: nil)
                
            case .failure(let error):
                
                switch error {
                
                case .timeOut:
                    let viewModel = AlertMessageViewModel(
                        title: "Timed Out",
                        message: "Timed out creating remote share session.",
                        cancelTitle: nil,
                        acceptTitle: "OK",
                        acceptHandler: nil
                    )
                    let view = AlertMessageView(viewModel: viewModel)
                    
                    navigationController.present(view.controller, animated: true, completion: nil)
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
            didViewToolScreenShareUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getDidViewToolScreenShareUseCase()
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
            getCreatingToolScreenShareSessionInterfaceStringsUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getCreatingToolScreenShareSessionInterfaceStringsUseCase(),
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
}
