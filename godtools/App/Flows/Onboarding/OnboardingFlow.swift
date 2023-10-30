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
    
    @Published private var quickStartIsAvailable: Bool = false
    @Published private var currentAppLanguage: AppLanguageCodeDomainModel = LanguageCodeDomainModel.english.value
    
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
        
        let getCurrentAppLanguageUseCase = appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase()
        let getOnboardingQuickStartIsAvailableUseCase = appDiContainer.feature.onboarding.domainLayer.getOnboardingQuickStartIsAvailableUseCase()
        
        getOnboardingQuickStartIsAvailableUseCase
            .getAvailablePublisher(appLanguageCodeChangedPublisher: getCurrentAppLanguageUseCase.getLanguagePublisher())
            .receive(on: DispatchQueue.main)
            .assign(to: &$quickStartIsAvailable)
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentAppLanguage)
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
            navigateToQuickLinksIfAvailableElseCompleteOnboarding()
            
        case .endTutorialFromOnboardingTutorial:
            navigateToQuickLinksIfAvailableElseCompleteOnboarding()

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
        
        let videoPlayerParameters: [String: Any] = [
            YoutubePlayerParameters.interfaceLanguage.rawValue: currentAppLanguage
        ]
        
        let viewModel = FullScreenVideoViewModel(
            flowDelegate: self,
            videoId: youtubeVideoId,
            videoPlayerParameters: videoPlayerParameters,
            userDidCloseVideoStep: .closeVideoPlayerTappedFromOnboardingTutorial,
            videoEndedStep: .videoEndedOnOnboardingTutorial
        )
        
        presentVideoModal(viewModel: viewModel, screenAccessibility: .watchOnboardingTutorialVideo, closeVideoButtonAccessibility: .closeOnboardingTutorialVideo)
    }
    
    private func navigateToQuickLinksIfAvailableElseCompleteOnboarding() {
        
        if quickStartIsAvailable {
            navigationController.setViewControllers([getOnboardingQuickStartView()], animated: true)
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
            trackViewedOnboardingTutorialUseCase: appDiContainer.feature.onboarding.domainLayer.getTrackViewedOnboardingTutorialUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getOnboardingTutorialInterfaceStringsUseCase: appDiContainer.feature.onboarding.domainLayer.getOnboardingTutorialInterfaceStringsUseCase(),
            trackTutorialVideoAnalytics: appDiContainer.dataLayer.getTutorialVideoAnalytics(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
                
        let view = OnboardingTutorialView(viewModel: viewModel)
        
        let skipButton = AppSkipBarItem(
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            target: viewModel,
            action: #selector(viewModel.skipTapped),
            accessibilityIdentifier: AccessibilityStrings.Button.skipOnboardingTutorial.id,
            toggleVisibilityPublisher: viewModel.hidesSkipButtonPublisher
        )
        
        let hostingView = AppHostingController<OnboardingTutorialView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: [skipButton],
                titleView: InvisibleChooseAppLanguageButtonForNavigationBar(tappedClosure: {
                    viewModel.chooseAppLanguageTapped()
                })
            )
        )
                        
        return hostingView
    }
    
    private func getOnboardingQuickStartView() -> UIViewController {
        
        let viewModel = OnboardingQuickStartViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getOnboardingQuickStartInterfaceStringsUseCase: appDiContainer.feature.onboarding.domainLayer.getOnboardingQuickStartInterfaceStringsUseCase(),
            getOnboardingQuickStartLinksUseCase: appDiContainer.feature.onboarding.domainLayer.getOnboardingQuickStartLinksUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
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
