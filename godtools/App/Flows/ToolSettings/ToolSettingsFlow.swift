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
    
    private let toolSettingsObserver: ToolSettingsObserver
    
    private var toolScreenShareFlow: ToolScreenShareFlow?
    private var languagesListModal: UIViewController?
    private var reviewShareShareableModal: UIViewController?
    private var downloadToolTranslationsFlow: DownloadToolTranslationsFlow?
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var viewShareToolDomainModel: ViewShareToolDomainModel?
    @Published private var toolScreenShareTutorialHasBeenViewedDomainModel: ToolScreenShareTutorialViewedDomainModel = ToolScreenShareTutorialViewedDomainModel(numberOfViews: 0)
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, toolSettingsObserver: ToolSettingsObserver) {
            
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.toolSettingsObserver = toolSettingsObserver
        
        let getToolScreenShareTutorialHasBeenViewedUseCase: GetToolScreenShareTutorialHasBeenViewedUseCase = appDiContainer.feature.toolScreenShare.domainLayer.getToolScreenShareTutorialHasBeenViewedUseCase()
                
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)

        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewShareToolDomainModel, Never> in
               
                return appDiContainer.feature.toolSettings.domainLayer
                    .getViewShareToolUseCase()
                    .viewPublisher(
                        toolId: toolSettingsObserver.toolId,
                        toolLanguageId: toolSettingsObserver.languages.selectedLanguageId,
                        pageNumber: toolSettingsObserver.pageNumber,
                        appLanguage: appLanguage
                    )
                    .eraseToAnyPublisher()
            })
            .sink { [weak self] (domainModel: ViewShareToolDomainModel) in
                self?.viewShareToolDomainModel = domainModel
            }
            .store(in: &cancellables)
        
        getToolScreenShareTutorialHasBeenViewedUseCase
            .getViewedPublisher(toolId: toolSettingsObserver.toolId)
            .receive(on: DispatchQueue.main)
            .assign(to: &$toolScreenShareTutorialHasBeenViewedDomainModel)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
            
        case .primaryLanguageTappedFromToolSettingsToolLanguagesList:
            dismissToolLanguagesList(animated: true)
            
        case .parallelLanguageTappedFromToolSettingsToolLanguagesList:
            dismissToolLanguagesList(animated: true)
            
        case .deleteParallelLanguageTappedFromToolSettingsToolLanguagesList:
            dismissToolLanguagesList(animated: true)
            
        default:
            break
        }
    }
}

// MARK: -

extension ToolSettingsFlow {
    
    private func getToolSettingsView() -> TransparentModalCustomView {
        
        let viewModel = ToolSettingsViewModel(
            flowDelegate: self,
            toolSettingsObserver: toolSettingsObserver,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewToolSettingsUseCase: appDiContainer.feature.toolSettings.domainLayer.getViewToolSettingsUseCase(),
            getShareablesUseCase: appDiContainer.feature.shareables.domainLayer.getShareablesUseCase(),
            getShareableImageUseCase: appDiContainer.feature.shareables.domainLayer.getShareableImageUseCase()
        )
        
        let toolSettingsView = ToolSettingsView(viewModel: viewModel)
        
        let hostingView = ToolSettingsHostingView(
            view: toolSettingsView,
            navigationBar: nil
        )
        
        return hostingView
    }
    
    private func getShareToolView(viewShareToolDomainModel: ViewShareToolDomainModel) -> UIViewController {
                
        let viewModel = ShareToolViewModel(
            viewShareToolDomainModel: viewShareToolDomainModel,
            toolId: toolSettingsObserver.toolId,
            toolAnalyticsAbbreviation: appDiContainer.dataLayer.getResourcesRepository().getResource(id: toolSettingsObserver.toolId)?.abbreviation ?? "",
            pageNumber: toolSettingsObserver.pageNumber,
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
            toolId: toolSettingsObserver.toolId,
            toolSettingsObserver: toolSettingsObserver,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewToolSettingsToolLanguageListUseCase: appDiContainer.feature.toolSettings.domainLayer.getViewToolSettingsToolLanguagesListUseCase()
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
            toolSettingsObserver: toolSettingsObserver
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
            toolId: toolSettingsObserver.toolId,
            shareable: shareable,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewReviewShareShareableUseCase: appDiContainer.feature.shareables.domainLayer.getViewReviewShareShareableUseCase(),
            getShareableImageUseCase: appDiContainer.feature.shareables.domainLayer.getShareableImageUseCase(),
            trackShareShareableTapUseCase: appDiContainer.feature.shareables.domainLayer.getTrackShareShareableTapUseCase()
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
