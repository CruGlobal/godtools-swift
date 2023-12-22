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
    
    private var toolScreenShareFlow: ToolScreenShareFlow?
    private var languagesListModal: UIViewController?
    private var reviewShareShareableModal: UIViewController?
    private var downloadToolTranslationsFlow: DownloadToolTranslationsFlow?
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var viewShareToolDomainModel: ViewShareToolDomainModel?
    @Published private var toolScreenShareTutorialHasBeenViewedDomainModel: ToolScreenShareTutorialViewedDomainModel = ToolScreenShareTutorialViewedDomainModel(numberOfViews: 0)
    @Published private var primaryLanguage: LanguageDomainModel
    @Published private var parallelLanguage: LanguageDomainModel?
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, toolData: ToolSettingsFlowToolData, tool: ToolSettingsToolType) {
            
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolData = toolData
        self.tool = tool
        
        primaryLanguage = toolData.renderer.value.primaryLanguage
        
        appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewShareToolDomainModel, Never> in
                return self.appDiContainer.feature.toolSettings.domainLayer.getViewShareToolUseCase()
                    .viewPublisher(
                        tool: toolData.renderer.value.resource,
                        toolLanguage: toolData.currentPageRenderer.value.language,
                        pageNumber: toolData.pageNumber,
                        appLanguage: appLanguage
                    )
                    .eraseToAnyPublisher()
            })
            .sink { [weak self] (domainModel: ViewShareToolDomainModel) in
                self?.viewShareToolDomainModel = domainModel
            }
            .store(in: &cancellables)
        
        initializeToolSettingsLanguages(
            primaryLanguage: toolData.renderer.value.primaryLanguage,
            parallelLanguage: toolData.renderer.value.pageRenderers[safe: 1]?.language
        )
        
        observeToolSettingsLanguageChanges()
        
        let getToolScreenShareTutorialHasBeenViewedUseCase: GetToolScreenShareTutorialHasBeenViewedUseCase = appDiContainer.feature.toolScreenShare.domainLayer.getToolScreenShareTutorialHasBeenViewedUseCase()
        
        getToolScreenShareTutorialHasBeenViewedUseCase
            .getViewedPublisher(tool: toolData.renderer.value.resource)
            .assign(to: &$toolScreenShareTutorialHasBeenViewedDomainModel)
        
        Publishers.CombineLatest(
            $primaryLanguage.eraseToAnyPublisher(),
            $parallelLanguage.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (primaryLanguage: LanguageDomainModel?, parallelLanguage: LanguageDomainModel?) in
            
            var languageIds: [String] = Array()
            
            if let primaryLanguage = primaryLanguage {
                languageIds.append(primaryLanguage.id)
            }
            
            if let parallelLanguage = parallelLanguage {
                languageIds.append(parallelLanguage.id)
            }
            
            self?.setToolLanguages(languageIds: languageIds)
        }
        .store(in: &cancellables)
    }
    
    private func initializeToolSettingsLanguages(primaryLanguage: LanguageDomainModel, parallelLanguage: LanguageDomainModel?) {
        
        appDiContainer.feature.toolSettings.domainLayer.getSetToolSettingsPrimaryLanguageUseCase()
            .setLanguagePublisher(languageId: primaryLanguage.dataModelId)
            .sink { _ in
                
            }
            .store(in: &cancellables)
        
        if let parallelLanguage = parallelLanguage {
            
            appDiContainer.feature.toolSettings.domainLayer.getSetToolSettingsParallelLanguageUseCase()
                .setLanguagePublisher(languageId: parallelLanguage.dataModelId)
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
    
    private func observeToolSettingsLanguageChanges() {
        
        let toolSettingsRepository: ToolSettingsRepository = appDiContainer.feature.toolSettings.dataLayer.getToolSettingsRepository()
        
        let getLanguageUseCase: GetLanguageUseCase = appDiContainer.domainLayer.getLanguageUseCase()
        
        toolSettingsRepository
            .getToolSettingsChangedPublisher()
            .sink { [weak self] (toolSettings: ToolSettingsDataModel?) in
                
                if let primaryLanguageId = toolSettings?.primaryLanguageId, let language = getLanguageUseCase.getLanguage(id: primaryLanguageId) {
                    self?.primaryLanguage = language
                }

                if let parallelLanguageId = toolSettings?.parallelLanguageId {
                    self?.parallelLanguage = getLanguageUseCase.getLanguage(id: parallelLanguageId)
                }
                else {
                    self?.parallelLanguage = nil
                }
            }
            .store(in: &cancellables)
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
            
            guard let domainModel = viewShareToolDomainModel else {
                return
            }
            
            navigationController.present(getShareToolView(viewShareToolDomainModel: domainModel), animated: true, completion: nil)
                    
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
            
        case .shareableTappedFromToolSettings(let shareable):
            presentReviewShareShareable(shareable: shareable, animated: true)
            
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
            
        case .primaryLanguageTappedFromToolSettingsToolLanguagesList( _):
            dismissToolLanguagesList(animated: true)
            
        case .parallelLanguageTappedFromToolSettingsToolLanguagesList( _):
            dismissToolLanguagesList(animated: true)
            
        case .deleteParallelLanguageTappedFromToolSettingsToolLanguagesList:
            dismissToolLanguagesList(animated: true)
            
        default:
            break
        }
    }
    
    private func setToolLanguages(languageIds: [String]) {
                
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
            tool: toolData.renderer.value.resource,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewToolSettingsUseCase: appDiContainer.feature.toolSettings.domainLayer.getViewToolSettingsUseCase(),
            getToolSettingsPrimaryLanguageUseCase: appDiContainer.feature.toolSettings.domainLayer.getToolSettingsPrimaryLanguageUseCase(),
            setToolSettingsPrimaryLanguageUseCase: appDiContainer.feature.toolSettings.domainLayer.getSetToolSettingsPrimaryLanguageUseCase(),
            setToolSettingsParallelLanguageUseCase: appDiContainer.feature.toolSettings.domainLayer.getSetToolSettingsParallelLanguageUseCase(),
            getShareablesUseCase: appDiContainer.feature.shareables.domainLayer.getShareablesUseCase(),
            getShareableImageUseCase: appDiContainer.feature.shareables.domainLayer.getShareableImageUseCase(),
            currentPageRenderer: toolData.currentPageRenderer,
            trainingTipsEnabled: toolData.trainingTipsEnabled
        )
        
        let toolSettingsView = ToolSettingsView(viewModel: viewModel)
        
        let hostingView = ToolSettingsHostingView(
            view: toolSettingsView,
            navigationBar: nil
        )
        
        return hostingView
    }
    
    private func getShareToolView(viewShareToolDomainModel: ViewShareToolDomainModel) -> UIViewController {
        
        let resource: ResourceModel = toolData.renderer.value.resource
        
        let viewModel = ShareToolViewModel(
            viewShareToolDomainModel: viewShareToolDomainModel,
            resource: resource,
            pageNumber: toolData.pageNumber,
            incrementUserCounterUseCase: appDiContainer.domainLayer.getIncrementUserCounterUseCase(),
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
            primaryLanguage: primaryLanguage,
            parallelLanguage: parallelLanguage
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
    
    private func presentReviewShareShareable(shareable: ShareableDomainModel, animated: Bool) {
        
        let reviewShareShareableView = getReviewShareShareableView(shareable: shareable)
        
        reviewShareShareableModal = reviewShareShareableView
        
        navigationController.present(reviewShareShareableView, animated: animated, completion: nil)
    }
    
    private func getReviewShareShareableView(shareable: ShareableDomainModel) -> UIViewController {
        
        let viewModel = ReviewShareShareableViewModel(
            flowDelegate: self,
            resource: toolData.renderer.value.resource,
            shareable: shareable,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewReviewShareShareableUseCase: appDiContainer.feature.shareables.domainLayer.getViewReviewShareShareableUseCase(),
            getShareableImageUseCase: appDiContainer.feature.shareables.domainLayer.getShareableImageUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
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
