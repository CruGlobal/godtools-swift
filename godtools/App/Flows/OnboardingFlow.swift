//
//  OnboardingFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
        
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController(nibName: nil, bundle: nil)
                
        navigationController.modalPresentationStyle = .fullScreen
        
        navigationController.setNavigationBarHidden(false, animated: false)
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: .clear,
            controlColor: nil,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: true
        )
        
        let onboardingTutorialItemsRepository = OnboardingTutorialItemsRepository(localizationServices: appDiContainer.localizationServices)
        
        let viewModel = OnboardingTutorialViewModel(
            flowDelegate: self,
            analyticsContainer: appDiContainer.analytics,
            onboardingTutorialItemsRepository: onboardingTutorialItemsRepository,
            onboardingTutorialAvailability: appDiContainer.onboardingTutorialAvailability,
            openTutorialCalloutCache: appDiContainer.openTutorialCalloutCache,
            customViewBuilder: appDiContainer.onboardingTutorialCustomViewBuilder(flowDelegate: self),
            localizationServices: appDiContainer.localizationServices
        )
        let view = OnboardingTutorialView(viewModel: viewModel)
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    private func launchVideoPlayerView(youtubeVideoId: String) {
        
        let viewModel = VideoPlayerViewModel(flowDelegate: self, youtubeVideoId: youtubeVideoId, closeVideoPlayerFlowStep: .closeVideoPlayerTappedFromOnboardingTutorial, videoEndedFlowStep: .videoEndedOnOnboardingTutorial)
        
        let view = VideoPlayerView(viewModel: viewModel)
        
        let modal = ModalNavigationController(rootView: view)
        modal.navigationBar.setupNavigationBarAppearance(backgroundColor: UIColor.black, controlColor: nil, titleFont: nil, titleColor: nil, isTranslucent: true)
        
        navigationController.present(modal, animated: true, completion: nil)
    }
    
    private func dismissVideoPlayerView() {
        
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    private func dismissOnboardingFlow() {
        
        flowDelegate?.navigate(step: .dismissOnboardingTutorial)
    }
}

extension OnboardingFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .videoButtonTappedFromOnboardingTutorial(let youtubeVideoId):
            launchVideoPlayerView(youtubeVideoId: youtubeVideoId)
        
        case .closeVideoPlayerTappedFromOnboardingTutorial:
            dismissVideoPlayerView()
            
        case .videoEndedOnOnboardingTutorial:
            dismissVideoPlayerView()
            
        case .skipTappedFromOnboardingTutorial:
            dismissOnboardingFlow()
            
        case .endTutorialFromOnboardingTutorial:
            dismissOnboardingFlow()
        
        default:
            break
        }
    }
}
