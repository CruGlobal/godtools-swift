//
//  ToolSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class ToolSettingsFlow: Flow {
    
    private let tool: ToolSettingsToolType
    private let trainingTipsEnabled: Bool
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let resource: ResourceModel
    private let selectedLanguage: LanguageModel
    private let primaryLanguage: LanguageModel
    private let parallelLanguage: LanguageModel?
    private let pageNumber: Int
    
    private var shareToolScreenTutorialModal: UIViewController?
    private var loadToolRemoteSessionModal: UIViewController?
    private var languagesListModal: UIViewController?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, tool: ToolSettingsToolType, trainingTipsEnabled: Bool, tractRemoteSharePublisher: TractRemoteSharePublisher, resource: ResourceModel, selectedLanguage: LanguageModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, pageNumber: Int, hidesRemoteShareToolAction: Bool) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.tool = tool
        self.trainingTipsEnabled = trainingTipsEnabled
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.resource = resource
        self.selectedLanguage = selectedLanguage
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage
        self.pageNumber = pageNumber
    }
    
    func getInitialView() -> UIViewController {
        
        let viewModel = ToolSettingsViewModel(flowDelegate: self, trainingTipsEnabled: trainingTipsEnabled)
        
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
                resource: resource,
                language: selectedLanguage,
                pageNumber: pageNumber,
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
            
            let shareToolScreenTutorialNumberOfViewsCache: ShareToolScreenTutorialNumberOfViewsCache = appDiContainer.shareToolScreenTutorialNumberOfViewsCache
            let numberOfTutorialViews: Int = shareToolScreenTutorialNumberOfViewsCache.getNumberOfViews(resource: resource)
            
            if tractRemoteSharePublisher.webSocketIsConnected, let channel = tractRemoteSharePublisher.tractRemoteShareChannel {
                navigate(step: .finishedLoadingToolRemoteSession(result: .success(channel)))
            }
            else if numberOfTutorialViews >= 3 || (tractRemoteSharePublisher.webSocketIsConnected && tractRemoteSharePublisher.tractRemoteShareChannel != nil) {
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
                
                let tractRemoteShareURLBuilder: TractRemoteShareURLBuilder = appDiContainer.tractRemoteShareURLBuilder
                
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
                        
            let languagesRepository: LanguagesRepository = appDiContainer.getLanguagesRepository()
            let getToolLanguagesUseCase: GetToolLanguagesUseCase = GetToolLanguagesUseCase(languagesRepository: languagesRepository)
            let languages: [ToolLanguageModel] = getToolLanguagesUseCase.getToolLanguages(resource: resource)
            
            let viewModel = LanguagesListViewModel(languages: languages, closeTappedClosure: { [weak self] in
                self?.dismissLanguagesList()
            }, languageTappedClosure: { [weak self] language in
                self?.tool.setPrimaryLanguage(languageId: language.id)
                self?.dismissLanguagesList()
                self?.flowDelegate?.navigate(step: .toolSettingsFlowCompleted)
            })
            
            let view = LanguagesListView(viewModel: viewModel)
            
            presentLanguagesList(languagesList: view)
            
        case .parallelLanguageTappedFromToolSettings:
            break
            
        case .swapLanguagesTappedFromToolSettings:
            break
            
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
            shareToolScreenTutorialNumberOfViewsCache: appDiContainer.shareToolScreenTutorialNumberOfViewsCache,
            resource: resource,
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
            tractRemoteSharePublisher: tractRemoteSharePublisher
        )
        let view = LoadingView(viewModel: viewModel)
        
        let modal = ModalNavigationController(rootView: view)
        
        navigationController.present(modal, animated: true, completion: nil)
        
        loadToolRemoteSessionModal = modal
    }
    
    private func presentLanguagesList(languagesList: LanguagesListView) {
        
        let hostingView: UIHostingController<LanguagesListView> = UIHostingController(rootView: languagesList)
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
