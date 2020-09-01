//
//  ShareToolMenuFlow.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolMenuFlow: Flow {

    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let resource: ResourceModel
    private let selectedLanguage: LanguageModel
    private let primaryLanguage: LanguageModel
    private let parallelLanguage: LanguageModel?
    private let pageNumber: Int
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, navigationController: UINavigationController, tractRemoteSharePublisher: TractRemoteSharePublisher, resource: ResourceModel, selectedLanguage: LanguageModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, pageNumber: Int) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = navigationController
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.resource = resource
        self.selectedLanguage = selectedLanguage
        self.primaryLanguage = primaryLanguage
        self.parallelLanguage = parallelLanguage
        self.pageNumber = pageNumber
        
        let viewModel = ShareToolMenuViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices,
            resource: resource,
            language: primaryLanguage,
            pageNumber: pageNumber
        )
        let view = ShareToolMenuView(viewModel: viewModel)
        
        navigationController.present(view.controller, animated: true, completion: nil)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .shareToolTappedFromShareToolMenu(let resource, let language, let pageNumber):
            
            let viewModel = ShareToolViewModel(
                resource: resource,
                language: language,
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
            
        case .remoteShareToolTappedFromShareToolMenu:
            
            let shareToolScreenTutorialNumberOfViewsCache: ShareToolScreenTutorialNumberOfViewsCache = appDiContainer.shareToolScreenTutorialNumberOfViewsCache
            
            let numberOfTutorialViews: Int = shareToolScreenTutorialNumberOfViewsCache.getNumberOfViews(resource: resource)
            
            if numberOfTutorialViews >= 3 {
                navigateToLoadToolRemoteSession()
            }
            else {
                navigateToShareToolScreenTutorial()
            }
            
        case .closeTappedFromShareToolScreenTutorial:
            
            navigationController.dismiss(animated: true, completion: nil)
            flowDelegate?.navigate(step: .closeTappedFromShareToolScreenTutorial)
            
        case .shareLinkTappedFromShareToolScreenTutorial:
            
            navigationController.dismiss(animated: true, completion: nil)
            
            navigateToLoadToolRemoteSession()
                        
        case .finishedLoadingToolRemoteSession(let toolRemoteShareUrl):
            
            navigationController.dismiss(animated: true, completion: nil)
            
            guard let remoteShareUrl = toolRemoteShareUrl else {
                // TODO: Show error that url could not be created. ~Levi
                return
            }
            
            let viewModel = ShareToolRemoteSessionURLViewModel(
                toolRemoteShareUrl: remoteShareUrl,
                localizationServices: appDiContainer.localizationServices,
                analytics: appDiContainer.analytics
            )
            let view = ShareToolRemoteSessionURLView(viewModel: viewModel)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
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
            resource: resource
        )

        let view = ShareToolScreenTutorialView(viewModel: viewModel)
        let modal = ModalNavigationController(rootView: view)

        navigationController.present(
            modal,
            animated: true,
            completion: nil
        )
    }
    
    private func navigateToLoadToolRemoteSession() {
        
        let viewModel = LoadToolRemoteSessionViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices,
            tractRemoteSharePublisher: tractRemoteSharePublisher,
            tractRemoteShareURLBuilder: appDiContainer.tractRemoteShareURLBuilder,
            resource: resource,
            primaryLanguage: primaryLanguage,
            parallelLanguage: parallelLanguage
        )
        let view = LoadingView(viewModel: viewModel)
        
        navigationController.present(view, animated: true, completion: nil)
    }
}
