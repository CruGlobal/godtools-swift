//
//  ToolSettingsFlow+ToolScreenShare.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit

extension ToolSettingsFlow {
 
    func getToolScreenShareTutorialView(toolSettingsObserver: ToolScreenShareSettingsObserver) -> UIViewController {
        
        let toolScreenShareTutorialViewed = appDiContainer.feature.toolScreenShare.domainLayer
            .getToolScreenShareTutorialHasBeenViewedUseCase()
            .execute(
                toolId: toolSettingsObserver.toolId
            )
        
        let showTutorialPages: ShowToolScreenShareTutorialPages
        
        if toolScreenShareTutorialViewed || toolSettingsObserver.tractRemoteSharePublisher.webSocketIsConnected {
            showTutorialPages = .lastPageWithQRCodeOption
        }
        else {
            showTutorialPages = .allPages
        }
        
        let viewModel = ToolScreenShareTutorialViewModel(
            stepEmitter: stepEmitter,
            toolId: toolSettingsObserver.toolId,
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
            localizationServices: appDiContainer.core.dataLayer.getLocalizationServices(),
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
        
        let tutorialView = AppHostingController<ToolScreenShareTutorialView>(
            rootView: view,
            navigationBar: navigationBar
        )
        
        let modal = ModalNavigationController.defaultModal(
            rootView: tutorialView,
            statusBarStyle: .default
        )
        
        return modal
    }
    
    func presentCreatingToolScreenShareSession(
        toolSettingsObserver: ToolScreenShareSettingsObserver,
        createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger
    ) {
        
        let tractRemoteSharePublisher: TractRemoteSharePublisher = toolSettingsObserver.tractRemoteSharePublisher
        
        if tractRemoteSharePublisher.webSocketIsConnected, let channel = tractRemoteSharePublisher.tractRemoteShareChannel {
            
            navigate(
                step: AppFlowStep.didCreateSessionFromCreatingToolScreenShareSession(
                    result: .success(channel),
                    createSessionTrigger: createSessionTrigger
                )
            )
            
            return
        }

        toggleInitialView(
            view: getCreatingToolScreenShareSessionView(
                toolSettingsObserver: toolSettingsObserver,
                createSessionTrigger: createSessionTrigger
            ),
            animated: true
        )
    }
    
    func getCreatingToolScreenShareSessionView(
        toolSettingsObserver: ToolScreenShareSettingsObserver,
        createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger
    ) -> UIViewController {
        
        let viewModel = CreatingToolScreenShareSessionViewModel(
            stepEmitter: stepEmitter,
            toolId: toolSettingsObserver.toolId,
            createSessionTrigger: createSessionTrigger,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
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
        
        let creatingToolScreenShareSessionView = AppHostingController<CreatingToolScreenShareSessionView>(
            rootView: view,
            navigationBar: navigationBar
        )
        
        let modal = ModalNavigationController.defaultModal(
            rootView: creatingToolScreenShareSessionView,
            statusBarStyle: .default
        )
        
        return modal
    }
    
    func getShareToolScreenShareSessionView(appLanguage: AppLanguageDomainModel, shareUrl: String) -> UIViewController {
                
        let viewModel = ShareToolScreenShareSessionViewModel(
            stepEmitter: stepEmitter,
            appLanguage: appLanguage,
            shareUrl: shareUrl,
            getShareToolScreenShareSessionStringsUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getShareToolScreenShareSessionStringsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
        )
        
        let view = ShareToolScreenShareSessionView(
            viewModel: viewModel
        )
        
        return view.controller
    }
    
    func getToolScreenShareQRCodeView(shareUrl: String) -> UIViewController {
        
        let viewModel = ToolScreenShareQRCodeViewModel(
            stepEmitter: stepEmitter,
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
    
    func getCreatingToolScreenShareSessionTimedOutView(appLanguage: AppLanguageDomainModel) -> UIViewController {
        
        let viewModel = CreatingToolScreenShareSessionTimedOutViewModel(
            stepEmitter: stepEmitter,
            appLanguage: appLanguage,
            getCreatingToolScreenShareSessionTimedOutStringsUseCase: appDiContainer.feature.toolScreenShare.domainLayer.getCreatingToolScreenShareSessionTimedOutStringsUseCase()
        )
        
        let view = CreatingToolScreenShareSessionTimedOutView(viewModel: viewModel)
        
        return view.controller
    }
}
