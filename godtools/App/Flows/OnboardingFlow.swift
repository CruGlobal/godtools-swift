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
            tutorialVideoAnalytics: appDiContainer.getTutorialVideoAnalytics(),
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
        
        let modal = ModalNavigationController(rootView: view, navBarColor: .black, navBarIsTranslucent: true)
        
        navigationController.present(modal, animated: true, completion: nil)
    }
    
    private func dismissVideoPlayerView() {
        
        navigationController.dismiss(animated: true, completion: nil)
    }

     private func navigateToQuickStartOrTools() {
         
         if appDiContainer.deviceLanguage.isEnglish {
             
             let viewModel = OnboardingQuickStartViewModel(flowDelegate: self, localizationServices: appDiContainer.localizationServices)
             let view = OnboardingQuickStartView(viewModel: viewModel)
             
             navigationController.setViewControllers([view], animated: true)
         }
         else {
             
             flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: nil))
         }
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
            navigateToQuickStartOrTools()
            
        case .endTutorialFromOnboardingTutorial:
            navigateToQuickStartOrTools()

        case .skipTappedFromOnboardingQuickStart:
            flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: nil))
            
        case .endTutorialFromOnboardingQuickStart:
            flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: nil))
        
        case .readArticlesTappedFromOnboardingQuickStart:
            flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: .readArticles))
        
        case .tryLessonsTappedFromOnboardingQuickStart:
            flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: .tryLessons))
        
        case .chooseToolTappedFromOnboardingQuickStart:
            flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: .chooseTool))
        
        default:
            break
        }
    }
}
