//
//  ToolSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import GodToolsToolParser

class ToolSettingsFlow: Flow {
    
    private let toolData: ToolSettingsFlowToolData
    private let tool: ToolSettingsToolType
    
    private var shareToolScreenTutorialModal: UIViewController?
    private var loadToolRemoteSessionModal: UIViewController?
    private var languagesListModal: UIViewController?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, toolData: ToolSettingsFlowToolData, tool: ToolSettingsToolType) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolData = toolData
        self.tool = tool
    }
    
    func getInitialView() -> UIViewController {
        
        let viewModel = ToolSettingsViewModel(
            flowDelegate: self,
            manifestResourcesCache: toolData.manifestResourcesCache,
            localizationServices: appDiContainer.localizationServices,
            primaryLanguage: toolData.primaryLanguage,
            parallelLanguage: toolData.parallelLanguage,
            trainingTipsEnabled: toolData.trainingTipsEnabled,
            shareables: toolData.shareables
        )
        
        let toolSettingsView = ToolSettingsView(viewModel: viewModel)
        
        let hostingView = ToolSettingsHostingView(view: toolSettingsView)
        
        let transparentModal = TransparentModalView(
            flowDelegate: self,
            modalView: hostingView,
            closeModalFlowStep: .closeTappedFromToolSettings
        )
        
        return transparentModal
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .closeTappedFromToolSettings:
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted)
            
        case .shareLinkTappedFromToolSettings:
            
            let viewModel = ShareToolViewModel(
                resource: toolData.resource,
                language: toolData.selectedLanguage,
                pageNumber: toolData.pageNumber,
                localizationServices: appDiContainer.localizationServices,
                analytics: appDiContainer.analytics
            )
            
            let view = ShareToolView(viewModel: viewModel)
            
            navigationController.present(
                view.controller,
                animated: true,
                completion: nil
            )
            
        case .screenShareTappedFromToolSettings:
            
            let shareToolScreenTutorialNumberOfViewsCache: ShareToolScreenTutorialNumberOfViewsCache = appDiContainer.getShareToolScreenTutorialNumberOfViewsCache()
            let numberOfTutorialViews: Int = shareToolScreenTutorialNumberOfViewsCache.getNumberOfViews(resource: toolData.resource)
            
            if toolData.tractRemoteSharePublisher.webSocketIsConnected, let channel = toolData.tractRemoteSharePublisher.tractRemoteShareChannel {
                navigate(step: .finishedLoadingToolRemoteSession(result: .success(channel)))
            }
            else if numberOfTutorialViews >= 3 || (toolData.tractRemoteSharePublisher.webSocketIsConnected && toolData.tractRemoteSharePublisher.tractRemoteShareChannel != nil) {
                navigateToLoadToolRemoteSession()
            }
            else {
                navigateToShareToolScreenTutorial()
            }
            
        case .closeTappedFromShareToolScreenTutorial:
            
            shareToolScreenTutorialModal?.dismiss(animated: true, completion: nil)
            shareToolScreenTutorialModal = nil
            
            flowDelegate?.navigate(step: .closeTappedFromToolSettings)
            
        case .shareLinkTappedFromShareToolScreenTutorial:
            
            shareToolScreenTutorialModal?.dismiss(animated: true, completion: nil)
            shareToolScreenTutorialModal = nil
            
            navigateToLoadToolRemoteSession()
                        
        case .finishedLoadingToolRemoteSession(let result):
                        
            loadToolRemoteSessionModal?.dismiss(animated: true, completion: nil)
            loadToolRemoteSessionModal = nil
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted)
            
            switch result {
                
            case .success(let channel):
                
                let tractRemoteShareURLBuilder: TractRemoteShareURLBuilder = appDiContainer.getTractRemoteShareURLBuilder()
                
                guard let remoteShareUrl = tractRemoteShareURLBuilder.buildRemoteShareURL(resource: toolData.resource, primaryLanguage: toolData.primaryLanguage, parallelLanguage: toolData.parallelLanguage, subscriberChannelId: channel.subscriberChannelId) else {
                    
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
                    localizationServices: appDiContainer.localizationServices,
                    analytics: appDiContainer.analytics
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
            
        case .cancelledLoadingToolRemoteSession:
            
            loadToolRemoteSessionModal?.dismiss(animated: true, completion: nil)
            loadToolRemoteSessionModal = nil
            
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted)
            
        case .enableTrainingTipsTappedFromToolSettings:
            
            tool.setTrainingTipsEnabled(enabled: true)
                        
        case .disableTrainingTipsTappedFromToolSettings:
            
            tool.setTrainingTipsEnabled(enabled: false)
                        
        case .primaryLanguageTappedFromToolSettings:
                
            presentLanguagesList(languageListType: .primary)
            
        case .parallelLanguageTappedFromToolSettings:
            
            presentLanguagesList(languageListType: .parallel)
            
        case .swapLanguagesTappedFromToolSettings:
            break
            
        case .shareableTappedFromToolSettings(let shareable, let imageToShare):
            
            let viewModel = ShareShareableViewModel(
                shareable: shareable,
                imageToShare: imageToShare
            )
            
            let view = ShareShareableView(viewModel: viewModel)
                        
            navigationController.present(view, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    private func navigateToShareToolScreenTutorial() {
        
        let tutorialItemsProvider = ShareToolScreenTutorialItemProvider(localizationServices: appDiContainer.localizationServices)
                    
        let viewModel = ShareToolScreenTutorialViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices,
            tutorialItemsProvider: tutorialItemsProvider,
            shareToolScreenTutorialNumberOfViewsCache: appDiContainer.getShareToolScreenTutorialNumberOfViewsCache(),
            resource: toolData.resource,
            analyticsContainer: appDiContainer.analytics,
            tutorialVideoAnalytics: appDiContainer.getTutorialVideoAnalytics()
        )

        let view = ShareToolScreenTutorialView(viewModel: viewModel)
        let modal = ModalNavigationController(rootView: view)

        navigationController.present(
            modal,
            animated: true,
            completion: nil
        )
        
        self.shareToolScreenTutorialModal = modal
    }
    
    private func navigateToLoadToolRemoteSession() {
        
        let viewModel = LoadToolRemoteSessionViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices,
            tractRemoteSharePublisher: toolData.tractRemoteSharePublisher
        )
        let view = LoadingView(viewModel: viewModel)
        
        let modal = ModalNavigationController(rootView: view)
        
        navigationController.present(modal, animated: true, completion: nil)
        
        loadToolRemoteSessionModal = modal
    }
    
    private func presentLanguagesList(languageListType: ToolSettingsLanguageListType) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.getLanguagesRepository()
        let getToolLanguagesUseCase: GetToolLanguagesUseCase = GetToolLanguagesUseCase(languagesRepository: languagesRepository)
        let languages: [ToolLanguageModel] = getToolLanguagesUseCase.getToolLanguages(resource: toolData.resource)
        
        let viewModel = LanguagesListViewModel(languages: languages, closeTappedClosure: { [weak self] in
            
            self?.dismissLanguagesList()
            
        }, languageTappedClosure: { [weak self] language in
            
            switch languageListType {
            case .primary:
                self?.tool.setPrimaryLanguage(languageId: language.id)
            case .parallel:
                self?.tool.setParallelLanguage(languageId: language.id)
            }
            
            self?.dismissLanguagesList()
        })
        
        let view = LanguagesListView(viewModel: viewModel)
                
        let hostingView: UIHostingController<LanguagesListView> = UIHostingController(rootView: view)
        hostingView.modalPresentationStyle = .fullScreen
        hostingView.view.backgroundColor = .white
        
        navigationController.present(hostingView, animated: true)
        
        languagesListModal = hostingView
    }
    
    private func dismissLanguagesList() {
        
        guard let languagesListModal = languagesListModal else {
            return
        }
        
        languagesListModal.dismiss(animated: true, completion: nil)
        self.languagesListModal = nil
    }
}
