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
        
        let viewModel = OnboardingTutorialViewModel(
            flowDelegate: self,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analyticsContainer: appDiContainer.dataLayer.getAnalytics(),
            tutorialVideoAnalytics: appDiContainer.getTutorialVideoAnalytics(),
            onboardingTutorialItemsRepository: appDiContainer.dataLayer.getOnboardingTutorialItemsRepository(),
            onboardingTutorialViewedRepository: appDiContainer.dataLayer.getOnboardingTutorialViewedRepository(),
            customViewBuilder: appDiContainer.getOnboardingTutorialCustomViewBuilder(flowDelegate: self),
            localizationServices: appDiContainer.localizationServices
        )
        let view = OnboardingTutorialView(viewModel: viewModel)
        
        navigationController.setViewControllers([view], animated: false)
    }
    
    private func dismissModal() {
        
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    private func presentVideoPlayerView(youtubeVideoId: String) {
        
        let viewModel = VideoPlayerViewModel(flowDelegate: self, youtubeVideoId: youtubeVideoId, closeVideoPlayerFlowStep: .closeVideoPlayerTappedFromOnboardingTutorial, videoEndedFlowStep: .videoEndedOnOnboardingTutorial)
        let view = VideoPlayerView(viewModel: viewModel)
        let modal = ModalNavigationController(rootView: view, navBarColor: .black, navBarIsTranslucent: true)
        
        navigationController.present(modal, animated: true, completion: nil)
    }
    
    private func navigateToQuickStartOrTools() {
        
        let getOnboardingQuickLinksEnabledUseCase: GetOnboardingQuickLinksEnabledUseCase = appDiContainer.domainLayer.getOnboardingQuickLinksEnabledUseCase()
        
        if getOnboardingQuickLinksEnabledUseCase.getQuickLinksEnabled() {
            
            let viewModel = OnboardingQuickStartViewModel(
                flowDelegate: self,
                localizationServices: appDiContainer.localizationServices,
                getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
                getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
                trackActionAnalytics: appDiContainer.dataLayer.getAnalytics().trackActionAnalytics
            )
            
            let view = OnboardingQuickStartView(viewModel: viewModel)
            
            navigationController.setViewControllers([view], animated: true)
        }
        else {
            
            flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: nil))
        }
    }
    
    private func completeOnboardingFlow(onboardingFlowCompletedState: OnboardingFlowCompletedState?) {
        
        flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: onboardingFlowCompletedState))
    }
}

extension OnboardingFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .videoButtonTappedFromOnboardingTutorial(let youtubeVideoId):
            presentVideoPlayerView(youtubeVideoId: youtubeVideoId)
        
        case .closeVideoPlayerTappedFromOnboardingTutorial:
            dismissModal()
            
        case .videoEndedOnOnboardingTutorial:
            dismissModal()
            
        case .skipTappedFromOnboardingTutorial:
            navigateToQuickStartOrTools()
            
        case .endTutorialFromOnboardingTutorial:
            navigateToQuickStartOrTools()

        case .skipTappedFromOnboardingQuickStart:
            completeOnboardingFlow(onboardingFlowCompletedState: nil)

        case .endTutorialFromOnboardingQuickStart:
            completeOnboardingFlow(onboardingFlowCompletedState: nil)

        case .readArticlesTappedFromOnboardingQuickStart:
            completeOnboardingFlow(onboardingFlowCompletedState: .readArticles)
        
        case .tryLessonsTappedFromOnboardingQuickStart:
            completeOnboardingFlow(onboardingFlowCompletedState: .tryLessons)
            
        case .chooseToolTappedFromOnboardingQuickStart:
            completeOnboardingFlow(onboardingFlowCompletedState: .chooseTool)
        
        default:
            break
        }
    }
}
