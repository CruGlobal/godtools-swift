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
        
        let toolPrimaryLanguage: LanguageDomainModel = toolData.renderer.value.primaryLanguage
        let toolParallelLanguage: LanguageDomainModel? = toolData.renderer.value.pageRenderers[safe: 1]?.language
        
        appDiContainer.feature.toolSettings.domainLayer.getSetToolSettingsPrimaryLanguageUseCase()
            .storeLanguagePublisher(languageId: toolPrimaryLanguage.dataModelId)
            .sink { _ in
                
            }
            .store(in: &cancellables)
        
        if let toolParallelLanguage = toolParallelLanguage {
            
            appDiContainer.feature.toolSettings.domainLayer.getSetToolSettingsParallelLanguageUseCase()
                .storeLanguagePublisher(languageId: toolParallelLanguage.dataModelId)
                .sink { _ in
                    
                }
                .store(in: &cancellables)
        }
        else {
            
            appDiContainer.feature.toolSettings.domainLayer.getDeleteToolSettingsParallelLanguageUseCase()
                .deletePublisher()
                .sink { _ in
                    
                }
                .store(in: &cancellables)
        }
    }
    
    func getInitialView() -> UIViewController {
                    
        let transparentModal = TransparentModalView(
            flowDelegate: self,
            modalView: getToolSettingsView(),
            closeModalFlowStep: .closeTappedFromToolSettings
        )
        
        return transparentModal
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .closeTappedFromToolSettings:
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted(state: .userClosedToolSettings))
            
        case .shareLinkTappedFromToolSettings:
            navigationController.present(getShareToolView(), animated: true, completion: nil)
                    
        case .screenShareTappedFromToolSettings:
            presentToolScreenShareFlow()

        case .toolScreenShareFlowCompleted(let state):
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted(state: .toolScreenShareFlowCompleted(state: state)))
                        
        case .enableTrainingTipsTappedFromToolSettings:
            
            tool.setTrainingTipsEnabled(enabled: true)
                        
        case .disableTrainingTipsTappedFromToolSettings:
            
            tool.setTrainingTipsEnabled(enabled: false)
                        
        case .primaryLanguageTappedFromToolSettings:
            presentToolLanguagesList(listType: .choosePrimaryLanguage, animated: true)
            
        case .parallelLanguageTappedFromToolSettings:
            presentToolLanguagesList(listType: .chooseParallelLanguage, animated: true)
            
        case .closeTappedFromToolSettingsToolLanguagesList:
            dismissToolLanguagesList(animated: true)
            
        case .swapLanguagesTappedFromToolSettings:
            
            swapToolPrimaryAndParallelLanguage()
            
        case .shareableTappedFromToolSettings(let shareableImageDomainModel):
            presentReviewShareShareable(shareableImageDomainModel: shareableImageDomainModel, animated: true)
            
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
            
        case .primaryLanguageTappedFromToolSettingsToolLanguagesList(let language):
            dismissToolLanguagesList(animated: true)
            setToolPrimaryLanguage(languageId: language.dataModelId)
            
        case .parallelLanguageTappedFromToolSettingsToolLanguagesList(let language):
            dismissToolLanguagesList(animated: true)
            setToolParallelLanguage(languageId: language.dataModelId)
            
        case .deleteParallelLanguageTappedFromToolSettingsToolLanguagesList:
            dismissToolLanguagesList(animated: true)
            setToolParallelLanguage(languageId: nil)
            
        default:
            break
        }
    }
    
    private func presentLanguagesList(languageListType: ToolSettingsToolLanguagesListTypeDomainModel) {
        
        /*
        
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
        
        languagesListModal = hostingView*/
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
}

// MARK: -

extension ToolSettingsFlow {
    
    private func getToolSettingsView() -> TransparentModalCustomView {
        
        let viewModel = ToolSettingsViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewToolSettingsUseCase: appDiContainer.feature.toolSettings.domainLayer.getViewToolSettingsUseCase(),
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
        
        return hostingView
    }
    
    private func getShareToolView() -> UIViewController {
        
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
        
        return view.controller
    }
}

// MARK: - Tool Languages List

extension ToolSettingsFlow {
    
    private func presentToolLanguagesList(listType: ToolSettingsToolLanguagesListTypeDomainModel, animated: Bool) {
        
        navigationController.present(getToolSettingsToolLanguagesListView(listType: listType), animated: true)
    }
    
    private func dismissToolLanguagesList(animated: Bool) {
        
        guard let languagesListModal = languagesListModal else {
            return
        }
        
        languagesListModal.dismiss(animated: animated)
                
        self.languagesListModal = nil
    }
    
    private func getToolSettingsToolLanguagesListView(listType: ToolSettingsToolLanguagesListTypeDomainModel) -> UIViewController {
        
        let viewModel = ToolSettingsToolLanguagesListViewModel(
            flowDelegate: self,
            listType: listType,
            tool: toolData.renderer.value.resource,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolSettingsPrimaryLanguageUseCase: appDiContainer.feature.toolSettings.domainLayer.getToolSettingsPrimaryLanguageUseCase(),
            getToolSettingsParallelLanguageUseCase: appDiContainer.feature.toolSettings.domainLayer.getToolSettingsParallelLanguageUseCase(),
            viewToolSettingsToolLanguageListUseCase: appDiContainer.feature.toolSettings.domainLayer.getViewToolSettingsToolLanguagesListUseCase(),
            setToolSettingsPrimaryLanguageUseCase: appDiContainer.feature.toolSettings.domainLayer.getSetToolSettingsPrimaryLanguageUseCase(),
            setToolSettingsParallelLanguageUseCase: appDiContainer.feature.toolSettings.domainLayer.getSetToolSettingsParallelLanguageUseCase(),
            deleteToolSettingsParallelLanguageUseCase: appDiContainer.feature.toolSettings.domainLayer.getDeleteToolSettingsParallelLanguageUseCase()
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
                
        languagesListModal = hostingView
        
        return hostingView
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

// MARK: - Review Share Shareable

extension ToolSettingsFlow {
    
    private func presentReviewShareShareable(shareableImageDomainModel: ShareableImageDomainModel, animated: Bool) {
        
        let reviewShareShareableView = getReviewShareShareableView(shareableImageDomainModel: shareableImageDomainModel)
        
        reviewShareShareableModal = reviewShareShareableView
        
        navigationController.present(reviewShareShareableView, animated: animated, completion: nil)
    }
    
    private func getReviewShareShareableView(shareableImageDomainModel: ShareableImageDomainModel) -> UIViewController {
        
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
        
        return hostingView
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
