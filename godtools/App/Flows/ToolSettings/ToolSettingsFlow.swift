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
    private let settingsPrimaryLanguage: CurrentValueSubject<LanguageDomainModel, Never>
    private let settingsParallelLanguage: CurrentValueSubject<LanguageDomainModel?, Never>
    
    private var toolScreenShareFlow: ToolScreenShareFlow?
    private var languagesListModal: UIViewController?
    private var reviewShareShareableModal: UIViewController?
    private var downloadToolTranslationsFlow: DownloadToolTranslationsFlow?
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var toolScreenShareTutorialHasBeenViewedDomainModel: ToolScreenShareTutorialViewedDomainModel = ToolScreenShareTutorialViewedDomainModel(numberOfViews: 0)
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, toolData: ToolSettingsFlowToolData, tool: ToolSettingsToolType) {
            
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolData = toolData
        self.tool = tool
        self.settingsPrimaryLanguage = CurrentValueSubject(toolData.renderer.value.primaryLanguage)
        self.settingsParallelLanguage = CurrentValueSubject(toolData.renderer.value.pageRenderers[safe: 1]?.language)
        
        let getToolScreenShareTutorialHasBeenViewedUseCase: GetToolScreenShareTutorialHasBeenViewedUseCase = appDiContainer.feature.toolScreenShare.domainLayer.getToolScreenShareTutorialHasBeenViewedUseCase()
        
        getToolScreenShareTutorialHasBeenViewedUseCase
            .getViewedPublisher(tool: toolData.renderer.value.resource)
            .assign(to: &$toolScreenShareTutorialHasBeenViewedDomainModel)
    }
    
    func getInitialView() -> UIViewController {
            
        let viewModel = ToolSettingsViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            getShareableImageUseCase: appDiContainer.domainLayer.getShareableImageUseCase(),
            currentPageRenderer: toolData.currentPageRenderer,
            primaryLanguageSubject: settingsPrimaryLanguage,
            parallelLanguageSubject: settingsParallelLanguage,
            trainingTipsEnabled: toolData.trainingTipsEnabled
        )
        
        let toolSettingsView = ToolSettingsView(viewModel: viewModel)
        
        let hostingView = ToolSettingsHostingView(
            view: toolSettingsView,
            navigationBar: nil
        )
        
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
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted(state: .userClosedToolSettings))
            
        case .shareLinkTappedFromToolSettings:
                    
            let resource: ResourceModel = toolData.renderer.value.resource
            let language: LanguageDomainModel = toolData.currentPageRenderer.value.language
            
            let viewModel = ShareToolViewModel(
                resource: resource,
                language: language,
                pageNumber: toolData.pageNumber,
                incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase(),
                localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
                trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
                trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
            )
            
            let view = ShareToolView(viewModel: viewModel)
            
            navigationController.present(
                view.controller,
                animated: true,
                completion: nil
            )
                    
        case .screenShareTappedFromToolSettings:
            presentToolScreenShareFlow()

        case .toolScreenShareFlowCompleted(let state):
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted(state: .toolScreenShareFlowCompleted(state: state)))
                        
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
                trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
                shareableImageDomainModel: shareableImageDomainModel,
                localizationServices: appDiContainer.dataLayer.getLocalizationServices()
            )
            
            let view = ReviewShareShareableView(viewModel: viewModel)
            
            let hostingView = AppHostingController<ReviewShareShareableView>(
                rootView: view,
                navigationBar: nil
            )
            
            hostingView.view.backgroundColor = .white
            
            reviewShareShareableModal = hostingView
            
            navigationController.present(hostingView, animated: true, completion: nil)
            
        case .closeTappedFromReviewShareShareable:
            dismissReviewShareShareable()
                                    
        case .shareImageTappedFromReviewShareShareable(let imageToShare):
            
            dismissReviewShareShareable(animated: true) { [weak self] in
                
                guard let weakSelf = self else {
                    return
                }
                
                let viewModel = ShareShareableViewModel(
                    imageToShare: imageToShare,
                    incrementUserCounterUseCase: weakSelf.appDiContainer.domainLayer.getIncrementUserCounterUseCase()
                )
                
                let view = ShareShareableView(viewModel: viewModel)
                            
                weakSelf.navigationController.present(view, animated: true, completion: nil)
            }
            
        default:
            break
        }
    }
    
    private func presentLanguagesList(languageListType: ToolSettingsLanguageListType) {
        
        let getToolLanguagesUseCase: GetToolLanguagesUseCase = appDiContainer.domainLayer.getToolLanguagesUseCase()
  
        let toolLanguages: [LanguageDomainModel] = getToolLanguagesUseCase.getToolLanguages(resource: toolData.renderer.value.resource)
      
        var languagesList: [LanguageDomainModel] = toolLanguages
        
        let selectedLanguage: LanguageDomainModel?
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
        
        let viewModel = LanguagesListViewModel(languages: languagesList, selectedLanguageId: selectedLanguage?.id, localizationServices: appDiContainer.dataLayer.getLocalizationServices(), closeTappedClosure: { [weak self] in
            
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
                
        let hostingView = AppHostingController<LanguagesListView>(
            rootView: view,
            navigationBar: nil
        )
        
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
        
        let getLanguageUseCase: GetLanguageUseCase = appDiContainer.domainLayer.getLanguageUseCase()
        
        let determineToolTranslationsToDownload = DetermineToolTranslationsToDownload(
            resourceId: toolData.renderer.value.resource.id,
            languageIds: languageIds,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            translationsRepository: appDiContainer.dataLayer.getTranslationsRepository()
        )
        
        let didDownloadToolTranslationsClosure = { [weak self] (result: Result<ToolTranslationsDomainModel, Error>) in
                   
            guard let weakSelf = self else {
                return
            }
            
            switch result {
            
            case .success(let toolTranslations):
                
                if let primaryLanguageId = languageIds.first, let primaryLanguage = getLanguageUseCase.getLanguage(id: primaryLanguageId) {
                    weakSelf.settingsPrimaryLanguage.send(primaryLanguage)
                }
                
                if let parallelLanguageId = languageIds[safe: 1], let parallelLanguage = getLanguageUseCase.getLanguage(id: parallelLanguageId) {
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

// MARK: - Tool Screen Share Flow

extension ToolSettingsFlow {
    
    private func presentToolScreenShareFlow() {
        
        let toolScreenShareFlow = ToolScreenShareFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            toolData: toolData,
            primaryLanguage: settingsPrimaryLanguage.value,
            parallelLanguage: settingsParallelLanguage.value
        )
        
        self.toolScreenShareFlow = toolScreenShareFlow
    }
    
    private func dismissToolScreenShareFlow() {
        
        guard toolScreenShareFlow != nil else {
            return
        }
        
        navigationController.dismissPresented(animated: true, completion: nil)
        
        toolScreenShareFlow = nil
    }
}
