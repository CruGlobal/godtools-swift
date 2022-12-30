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

class ToolSettingsFlow: Flow {
    
    private let toolData: ToolSettingsFlowToolData
    private let tool: ToolSettingsToolType
    private let settingsPrimaryLanguage: CurrentValueSubject<LanguageModel, Never>
    private let settingsParallelLanguage: CurrentValueSubject<LanguageModel?, Never>
    
    private var shareToolScreenTutorialModal: UIViewController?
    private var loadToolRemoteSessionModal: UIViewController?
    private var languagesListModal: UIViewController?
    private var reviewShareShareableModal: UIViewController?
    private var downloadToolTranslationsFlow: DownloadToolTranslationsFlow?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, toolData: ToolSettingsFlowToolData, tool: ToolSettingsToolType) {
            
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolData = toolData
        self.tool = tool
        self.settingsPrimaryLanguage = CurrentValueSubject(toolData.renderer.value.primaryLanguage)
        self.settingsParallelLanguage = CurrentValueSubject(toolData.renderer.value.pageRenderers[safe: 1]?.language)
    }
    
    func getInitialView() -> UIViewController {
            
        let viewModel = ToolSettingsViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices,
            getTranslatedLanguageUseCase: appDiContainer.getTranslatedLanguageUseCase(),
            getShareableImageUseCase: appDiContainer.getShareableImageUseCase(),
            currentPageRenderer: toolData.currentPageRenderer,
            primaryLanguageSubject: settingsPrimaryLanguage,
            parallelLanguageSubject: settingsParallelLanguage,
            trainingTipsEnabled: toolData.trainingTipsEnabled
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
                    
            let resource: ResourceModel = toolData.renderer.value.resource
            let language: LanguageDomainModel = toolData.currentPageRenderer.value.language
            
            let viewModel = ShareToolViewModel(
                resource: resource,
                language: language,
                pageNumber: toolData.pageNumber,
                localizationServices: appDiContainer.localizationServices,
                getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
                getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
                analytics: appDiContainer.dataLayer.getAnalytics()
            )
            
            let view = ShareToolView(viewModel: viewModel)
            
            navigationController.present(
                view.controller,
                animated: true,
                completion: nil
            )
                    
        case .screenShareTappedFromToolSettings:
            
            let shareToolScreenTutorialNumberOfViewsCache: ShareToolScreenTutorialNumberOfViewsCache = appDiContainer.getShareToolScreenTutorialNumberOfViewsCache()
            let numberOfTutorialViews: Int = shareToolScreenTutorialNumberOfViewsCache.getNumberOfViews(resource: toolData.renderer.value.resource)
            
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
                
                let resource: ResourceModel = toolData.renderer.value.resource
                let primaryLanguage: LanguageModel = settingsPrimaryLanguage.value
                let parallelLanguage: LanguageModel? = settingsParallelLanguage.value
                
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
                    getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
                    getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
                    analytics: appDiContainer.dataLayer.getAnalytics()
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
            
            swapToolPrimaryAndParallelLanguage()
            
        case .shareableTappedFromToolSettings(let shareableImageDomainModel):
                   
            let viewModel = ReviewShareShareableViewModel(
                flowDelegate: self,
                getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
                getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
                analytics: appDiContainer.dataLayer.getAnalytics(),
                shareableImageDomainModel: shareableImageDomainModel,
                localizationServices: appDiContainer.localizationServices
            )
            
            let view = ReviewShareShareableView(viewModel: viewModel)
                        
            let hostingView: UIHostingController<ReviewShareShareableView> = UIHostingController(rootView: view)
            hostingView.view.backgroundColor = .white
            
            reviewShareShareableModal = hostingView
            
            navigationController.present(hostingView, animated: true, completion: nil)
            
        case .closeTappedFromReviewShareShareable:
            dismissReviewShareShareable()
                                    
        case .shareImageTappedFromReviewShareShareable(let imageToShare):
            
            dismissReviewShareShareable(animated: true) { [weak self] in
                
                let viewModel = ShareShareableViewModel(
                    imageToShare: imageToShare
                )
                
                let view = ShareShareableView(viewModel: viewModel)
                            
                self?.navigationController.present(view, animated: true, completion: nil)
            }
            
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
            resource: toolData.renderer.value.resource,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analyticsContainer: appDiContainer.dataLayer.getAnalytics(),
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
        
        let getToolLanguagesUseCase: GetToolLanguagesUseCase = appDiContainer.domainLayer.getToolLanguagesUseCase()
  
        let toolLanguages: [LanguageDomainModel] = getToolLanguagesUseCase.getToolLanguages(resource: toolData.renderer.value.resource)
      
        var languagesList: [LanguageDomainModel] = toolLanguages
        
        let selectedLanguage: LanguageModel?
        let deleteTappedClosure: (() -> Void)?
        
        switch languageListType {
        case .primary:
            
            if let parallelLanguageId = settingsParallelLanguage.value?.id {
                languagesList = languagesList.filter({$0.dataModelId != parallelLanguageId})
            }
            
            selectedLanguage = settingsPrimaryLanguage.value
            deleteTappedClosure = nil
            
        case .parallel:
            
            languagesList = languagesList.filter({$0.dataModelId != settingsPrimaryLanguage.value.id})
            
            selectedLanguage = settingsParallelLanguage.value
            deleteTappedClosure = { [weak self] in
                self?.setToolParallelLanguage(languageId: nil)
                self?.dismissLanguagesList()
            }
        }
        
        let viewModel = LanguagesListViewModel(languages: languagesList, selectedLanguageId: selectedLanguage?.id, localizationServices: appDiContainer.localizationServices, closeTappedClosure: { [weak self] in
            
            self?.dismissLanguagesList()
            
        }, languageTappedClosure: { [weak self] language in
            
            self?.dismissLanguagesList(animated: true, completion: { [weak self] in
                
                switch languageListType {
                case .primary:
                    self?.setToolPrimaryLanguage(languageId: language.dataModelId)
                case .parallel:
                    self?.setToolParallelLanguage(languageId: language.dataModelId)
                }
            })
        }, deleteTappedClosure: deleteTappedClosure)
        
        let view = LanguagesListView(viewModel: viewModel)
                
        let hostingView: UIHostingController<LanguagesListView> = UIHostingController(rootView: view)
        hostingView.view.backgroundColor = .white
        
        navigationController.present(hostingView, animated: true)
        
        languagesListModal = hostingView
    }
    
    private func setToolPrimaryLanguage(languageId: String) {
        
        var languageIds: [String] = Array()
        
        languageIds.append(languageId)
        
        if let parallelLanguageId = settingsParallelLanguage.value?.id {
            languageIds.append(parallelLanguageId)
        }
        
        setToolLanguages(languageIds: languageIds)
    }
    
    private func setToolParallelLanguage(languageId: String?) {
        
        var languageIds: [String] = Array()
        
        languageIds.append(settingsPrimaryLanguage.value.id)
        
        if let parallelLanguageId = languageId {
            languageIds.append(parallelLanguageId)
        }
        
        setToolLanguages(languageIds: languageIds)
    }
    
    private func swapToolPrimaryAndParallelLanguage() {
        
        guard let parallelLanguageId = settingsParallelLanguage.value?.id else {
            return
        }
        
        setToolLanguages(languageIds: [parallelLanguageId, settingsPrimaryLanguage.value.id])
    }
    
    private func setToolLanguages(languageIds: [String]) {
        
        let languagesRepository: LanguagesRepository = appDiContainer.dataLayer.getLanguagesRepository()
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: toolData.renderer.value.resource.id,
            languageIds: languageIds,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository()
        )
        
        let didDownloadToolTranslationsClosure = { [weak self] (result: Result<ToolTranslationsDomainModel, URLResponseError>) in
                   
            guard let weakSelf = self else {
                return
            }
            
            switch result {
            
            case .success(let toolTranslations):
                
                if let primaryLanguageId = languageIds.first, let primaryLanguage = languagesRepository.getLanguage(id: primaryLanguageId) {
                    weakSelf.settingsPrimaryLanguage.send(primaryLanguage)
                }
                
                if let parallelLanguageId = languageIds[safe: 1], let parallelLanguage = languagesRepository.getLanguage(id: parallelLanguageId) {
                    weakSelf.settingsParallelLanguage.send(parallelLanguage)
                }
                else {
                    weakSelf.settingsParallelLanguage.send(nil)
                }
                
                let newRenderer: MobileContentRenderer = weakSelf.toolData.renderer.value.copy(toolTranslations: toolTranslations)
                weakSelf.tool.setRenderer(renderer: newRenderer)
                
            case .failure( _):
                break
            }
            
            self?.downloadToolTranslationsFlow = nil
        }
        
        let downloadToolTranslationsFlow = DownloadToolTranslationsFlow(
            presentInFlow: self,
            appDiContainer: appDiContainer,
            determineToolTranslationsToDownload: determineToolTranslationsToDownload,
            didDownloadToolTranslations: didDownloadToolTranslationsClosure
        )
        
        self.downloadToolTranslationsFlow = downloadToolTranslationsFlow
    }
    
    private func dismissLanguagesList(animated: Bool = true, completion: (() -> Void)? = nil) {
        
        guard let languagesListModal = languagesListModal else {
            completion?()
            return
        }
        
        if animated {
            languagesListModal.dismiss(animated: true, completion: completion)
        }
        else {
            languagesListModal.dismiss(animated: false)
            completion?()
        }
                
        self.languagesListModal = nil
    }
    
    private func dismissReviewShareShareable(animated: Bool = true, completion: (() -> Void)? = nil) {
        
        guard let reviewShareShareableModal = reviewShareShareableModal else {
            completion?()
            return
        }
        
        if animated {
            reviewShareShareableModal.dismiss(animated: true, completion: completion)
        }
        else {
            reviewShareShareableModal.dismiss(animated: false)
            completion?()
        }
        
        self.reviewShareShareableModal = nil
    }
}
