//
//  OnboardingFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class OnboardingFlow: Flow, ChooseAppLanguageNavigationFlow {
            
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
            
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    var chooseAppLanguageFlow: ChooseAppLanguageFlow?
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        print("init: \(type(of: self))")
        
        let navigationBarAppearance = AppNavigationBarAppearance(
            backgroundColor: .clear,
            controlColor: ColorPalette.gtBlue.uiColor,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: true
        )
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = AppNavigationController(navigationBarAppearance: navigationBarAppearance)
        
        navigationController.modalPresentationStyle = .fullScreen
        
        navigationController.setViewControllers([getInitialView()], animated: false)
    }
    
    func getInitialView() -> UIViewController {
        
        return getOnboardingTutorialView()
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .chooseAppLanguageTappedFromOnboardingTutorial:
            navigateToChooseAppLanguageFlow()
            
        case .chooseAppLanguageFlowCompleted(let state):
            navigateBackFromChooseAppLanguageFlow()
            
        case .videoButtonTappedFromOnboardingTutorial(let youtubeVideoId):
            presentWatchOnboardingTutorialVideoPlayer(youtubeVideoId: youtubeVideoId)
        
        case .closeVideoPlayerTappedFromOnboardingTutorial:
            dismissVideoModal(animated: true, completion: nil)
            
        case .videoEndedOnOnboardingTutorial:
            dismissVideoModal(animated: true, completion: nil)
            
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
    
    private func presentWatchOnboardingTutorialVideoPlayer(youtubeVideoId: String) {
        
        let viewModel = FullScreenVideoViewModel(
            flowDelegate: self,
            videoId: youtubeVideoId,
            videoPlayerParameters: nil,
            userDidCloseVideoStep: .closeVideoPlayerTappedFromOnboardingTutorial,
            videoEndedStep: .videoEndedOnOnboardingTutorial
        )
        
        presentVideoModal(viewModel: viewModel, screenAccessibility: .watchOnboardingTutorialVideo, closeVideoButtonAccessibility: .closeOnboardingTutorialVideo)
    }
    
    private func navigateToQuickStartOrTools() {
        
        let getOnboardingQuickLinksEnabledUseCase: GetOnboardingQuickLinksEnabledUseCase = appDiContainer.domainLayer.getOnboardingQuickLinksEnabledUseCase()
        
        if getOnboardingQuickLinksEnabledUseCase.getQuickLinksEnabled() {
                        
            let view = getOnboardingQuickStartView()
            
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

// MARK: -

extension OnboardingFlow {
    
    private func getOnboardingTutorialView() -> UIViewController {
        
        let viewModel = OnboardingTutorialViewModel(
            flowDelegate: self,
            onboardingTutorialViewedRepository: appDiContainer.dataLayer.getOnboardingTutorialViewedRepository(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            trackTutorialVideoAnalytics: appDiContainer.dataLayer.getTutorialVideoAnalytics(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
                
        let view = OnboardingTutorialView(viewModel: viewModel)
        
        let skipButton = AppSkipBarItem(
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            target: viewModel,
            action: #selector(viewModel.skipTapped),
            accessibilityIdentifier: nil,
            toggleVisibilityPublisher: viewModel.hidesSkipButtonPublisher
        )
        
        let hostingView = AppHostingController<OnboardingTutorialView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: [skipButton],
                titleView: ChooseAppLanguageButtonUIKit(title: "Choose Language", tappedClosure: {
                    viewModel.chooseAppLanguageTapped()
                })
            )
        )
                        
        return hostingView
    }
    
    private func getOnboardingQuickStartView() -> UIViewController {
        
        let viewModel = OnboardingQuickStartViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            getOnboardingQuickStartItemsUseCase: appDiContainer.domainLayer.getOnboardingQuickStartItemsUseCase(),
            trackActionAnalytics: appDiContainer.dataLayer.getAnalytics().trackActionAnalytics
        )
        
        let view = OnboardingQuickStartView(viewModel: viewModel)
        
        let skipButton = AppSkipBarItem(
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            target: viewModel,
            action: #selector(viewModel.skipTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<OnboardingQuickStartView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: [skipButton]
            )
        )
        
        return hostingView
    }
}
