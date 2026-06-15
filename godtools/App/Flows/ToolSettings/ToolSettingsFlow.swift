//
//  ToolSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class ToolSettingsFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case failedToCreateToolScreenShareSession
        case userSharedQRCodeForToolScreenShareSession
        case userClosedToolScreenShare
        case userClosed
    }
    
    typealias ToolScreenShareSettingsObserver = ToolSettingsObserver & RemoteShareable
    
    private let toolSettingsObserver: ToolSettingsObserver
    private let toolSettingsDidCloseClosure: (() -> Void)?
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage = AppLanguageDomainModel.english
    @Published private var creatingToolScreenShareSessionTimedOutStringsDomainModel = CreatingToolScreenShareSessionTimedOutStringsDomainModel.emptyValue
    @Published private var shareToolScreenShareSessionStringsDomainModel = ShareToolScreenShareSessionStringsDomainModel.emptyValue
        
    init(appDiContainer: AppDiContainer, toolSettingsObserver: ToolSettingsObserver, toolSettingsDidCloseClosure: (() -> Void)?) {
            
        self.toolSettingsObserver = toolSettingsObserver
        self.toolSettingsDidCloseClosure = toolSettingsDidCloseClosure
                
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getToolSettingsView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                toolSettingsObserver: toolSettingsObserver
            ),
            stepEmitter: stepEmitter,
            onPresentType: .presentInitialView
        )
                                
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                appDiContainer.feature.toolScreenShare.domainLayer
                    .getCreatingToolScreenShareSessionTimedOutStringsUseCase()
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: CreatingToolScreenShareSessionTimedOutStringsDomainModel) in
                self?.creatingToolScreenShareSessionTimedOutStringsDomainModel = domainModel
            }
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                appDiContainer.feature.toolScreenShare.domainLayer
                    .getShareToolScreenShareSessionStringsUseCase()
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: ShareToolScreenShareSessionStringsDomainModel) in
                self?.shareToolScreenShareSessionStringsDomainModel = strings
            }
            .store(in: &cancellables)
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
            
        case .closeTappedFromToolSettings:
            completeFlow(state: .userClosed)
            
        case .shareLinkTappedFromToolSettings:
            
            let toolAbbreviation: String = appDiContainer.core.dataLayer.getResourcesRepository().getResourceById(id: toolSettingsObserver.toolId)?.abbreviation ?? ""
            
            let shareToolFlow = ShareToolFlow(
                appDiContainer: appDiContainer,
                toolId: toolSettingsObserver.toolId,
                toolLanguageId: toolSettingsObserver.languages.selectedLanguageId,
                pageNumber: toolSettingsObserver.pageNumber,
                appLanguage: appLanguage,
                toolAnalyticsAbbreviation: toolAbbreviation
            )
            
            dismissInitialView(animated: true, completion: { [weak self] in
                
                self?.presentFlow(
                    flow: shareToolFlow
                )
            })
            
        case .shareToolFlowCompleted( _):
            
            dismissFlow(completion: { [weak self] in
                
                self?.presentInitialView(animated: true)
            })
                    
        case .screenShareTappedFromToolSettings:
            
            guard let toolSettingsObserver = toolSettingsObserver as? ToolScreenShareSettingsObserver else {
                return
            }
            
            toggleInitialView(
                view: getToolScreenShareTutorialView(
                    toolSettingsObserver: toolSettingsObserver
                ),
                animated: true
            )
            
        case .closeTappedFromToolScreenShareTutorial:
            dismissInitialView(animated: true, completion: { [weak self] in
                self?.completeFlow(state: .userClosedToolScreenShare)
            })
            
        case .generateQRCodeTappedFromToolScreenShareTutorial:
           
            guard let toolSettingsObserver = toolSettingsObserver as? ToolScreenShareSettingsObserver else {
                return
            }
            
            presentCreatingToolScreenShareSession(
                toolSettingsObserver: toolSettingsObserver,
                createSessionTrigger: .generateQRCodeTappedFromScreenShareTutorial
            )
            
        case .shareLinkTappedFromToolScreenShareTutorial:
            
            guard let toolSettingsObserver = toolSettingsObserver as? ToolScreenShareSettingsObserver else {
                return
            }
            
            presentCreatingToolScreenShareSession(
                toolSettingsObserver: toolSettingsObserver,
                createSessionTrigger: .shareLinkTappedFromScreenShareTutorial
            )
            
        case .closeTappedFromCreatingToolScreenShareSession:
            
            dismissInitialView(animated: true, completion: { [weak self] in
                
                self?.completeFlow(state: .userClosedToolScreenShare)
            })
            
        case .shareQRCodeTappedFromToolScreenShareSession(let shareUrl):
            
            toggleInitialView(
                view: getToolScreenShareQRCodeView(shareUrl: shareUrl),
                animated: true
            )
            
        case .dismissedShareToolScreenShareActivityViewController:
            
            dismissInitialView(animated: true, completion: { [weak self] in
                
                self?.completeFlow(state: .userClosedToolScreenShare)
            })
            
        case .closeTappedFromShareToolScreenQRCode:

            dismissInitialView(animated: true, completion: { [weak self] in
                
                self?.completeFlow(state: .userSharedQRCodeForToolScreenShareSession)
            })

        case .didCreateSessionFromCreatingToolScreenShareSession(let result, let createSessionTrigger):
            
            switch result {
                
            case .success(let channel):
                
                let tractRemoteShareURLBuilder: TractRemoteShareURLBuilder = appDiContainer.feature.toolScreenShare.dataLayer.getTractRemoteShareURLBuilder()
                                
                guard let remoteShareUrl = tractRemoteShareURLBuilder.buildRemoteShareURL(
                    toolId: toolSettingsObserver.toolId,
                    primaryLanguageId: toolSettingsObserver.languages.primaryLanguageId,
                    parallelLanguageId: toolSettingsObserver.languages.parallelLanguageId,
                    selectedLanguageId: toolSettingsObserver.languages.selectedLanguageId,
                    page: toolSettingsObserver.pageNumber,
                    subscriberChannelId: channel.id
                ) else {

                    let view = AlertMessageView(
                        title: "Error",
                        message: "Failed to create remote share url.",
                        acceptTitle: "OK",
                        cancelTitle: nil,
                        acceptTapped: nil,
                        cancelTapped: nil
                    )
                    
                    presentView(view: view.controller, animated: true)
                    
                    return
                }
                                
                switch createSessionTrigger {
                    
                case .generateQRCodeTappedFromScreenShareTutorial:
                   
                    toggleInitialView(
                        view: getToolScreenShareQRCodeView(shareUrl: remoteShareUrl),
                        animated: true
                    )
                    
                case .shareLinkTappedFromScreenShareTutorial:
                    
                    toggleInitialView(
                        view: getShareToolScreenShareSessionView(
                            strings: shareToolScreenShareSessionStringsDomainModel,
                            shareUrl: remoteShareUrl
                        ),
                        animated: true
                    )
                }
                
            case .failure(let error):
                                
                switch error {
                
                case .timedOut:
                   
                    let strings = creatingToolScreenShareSessionTimedOutStringsDomainModel

                    presentView(
                        view: getCreatingToolScreenShareSessionTimedOutView(strings: strings),
                        animated: true
                    )
                }
            }
            
        case .cancelTappedFromCreateToolScreenShareSessionTimeout:
            completeFlow(state: .failedToCreateToolScreenShareSession)
            
        case .acceptTappedFromCreateToolScreenShareSessionTimeout:
            completeFlow(state: .failedToCreateToolScreenShareSession)
        
        case .primaryLanguageTappedFromToolSettings:
            presentView(
                view: getToolSettingsToolLanguagesListView(listType: .choosePrimaryLanguage),
                animated: true
            )
        
        case .parallelLanguageTappedFromToolSettings:
            presentView(
                view: getToolSettingsToolLanguagesListView(listType: .chooseParallelLanguage),
                animated: true
            )
                        
        case .closeTappedFromToolSettingsToolLanguagesList:
            dismissView(animated: true)
            
        case .primaryLanguageTappedFromToolSettingsToolLanguagesList:
            dismissView(animated: true)
            
        case .parallelLanguageTappedFromToolSettingsToolLanguagesList:
            dismissView(animated: true)
            
        case .deleteParallelLanguageTappedFromToolSettingsToolLanguagesList:
            dismissView(animated: true)
            
        case .shareableTappedFromToolSettings(let shareable):
            presentView(
                view: getReviewShareShareableView(toolSettingsObserver: toolSettingsObserver, shareable: shareable),
                animated: true
            )
                        
        case .closeTappedFromReviewShareShareable:
            dismissView(animated: true)
                                    
        case .shareImageTappedFromReviewShareShareable(let imageToShare):
            
            let viewModel = ShareShareableViewModel(
                stepEmitter: stepEmitter,
                imageToShare: imageToShare,
                incrementUserCounterUseCase: appDiContainer.feature.userActivity.domainLayer.getIncrementUserCounterUseCase()
            )
            
            let view = ShareShareableView(viewModel: viewModel)
            
            presentView(view: view, animated: true)
            
        case .dismissedShareShareableActivityViewController:
            dismissView(animated: true)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: ToolSettingsFlow.CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.toolSettingsFlowCompleted(state: state))
    }
}

// MARK: - ToolSettingsView

extension ToolSettingsFlow {
    
    private static func getToolSettingsView(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        toolSettingsObserver: ToolSettingsObserver
    ) -> AppHostingController<ToolSettingsView> {
        
        let viewModel = ToolSettingsViewModel(
            stepEmitter: stepEmitter,
            toolSettingsObserver: toolSettingsObserver,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolSettingsStringsUseCase: appDiContainer.feature.toolSettings.domainLayer.getToolSettingsStringsUseCase(),
            getToolSettingsUseCase: appDiContainer.feature.toolSettings.domainLayer.getToolSettingsUseCase(),
            getShareablesUseCase: appDiContainer.feature.shareables.domainLayer.getShareablesUseCase(),
            getShareableImageUseCase: appDiContainer.feature.shareables.domainLayer.getShareableImageUseCase()
        )
        
        let toolSettingsView = ToolSettingsView(viewModel: viewModel)
        
        let hostingView = AppHostingController<ToolSettingsView>(
            rootView: toolSettingsView,
            navigationBar: nil,
            animateInAnimatedTransitioning: NoAnimationTransition(transition: .transitionIn),
            animateOutAnimatedTransitioning: NoAnimationTransition(transition: .transitionOut)
        )

        hostingView.view.backgroundColor = .clear
        hostingView.modalPresentationStyle = .overCurrentContext
        
        return hostingView
    }
}

// MARK: - Tool Languages List

extension ToolSettingsFlow {
    
    private func getToolSettingsToolLanguagesListView(listType: ToolSettingsToolLanguagesListTypeDomainModel) -> UIViewController {
        
        let viewModel = ToolSettingsToolLanguagesListViewModel(
            stepEmitter: stepEmitter,
            listType: listType,
            toolId: toolSettingsObserver.toolId,
            toolSettingsObserver: toolSettingsObserver,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolSettingsToolLanguagesListStringsUseCase: appDiContainer.feature.toolSettings.domainLayer.getToolSettingsToolLanguagesListStringsUseCase(),
            getToolSettingsToolLanguagesListUseCase: appDiContainer.feature.toolSettings.domainLayer.getToolSettingsToolLanguagesListUseCase()
        )
        
        let view = ToolSettingsToolLanguagesListView(viewModel: viewModel)
        
        let navigationBar = AppNavigationBar(
            appearance: nil,
            backButton: nil,
            leadingItems: [],
            trailingItems: []
        )
        
        let hostingView = AppHostingController<ToolSettingsToolLanguagesListView>(
            rootView: view,
            navigationBar: navigationBar
        )

        hostingView.view.backgroundColor = .white
                        
        return hostingView
    }
}
