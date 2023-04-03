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
import SharedAppleExtensions

class OnboardingFlow: Flow {
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
        
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController(nibName: nil, bundle: nil)
                
        navigationController.modalPresentationStyle = .fullScreen
        
        navigationController.setNavigationBarHidden(false, animated: false)
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: .clear,
            controlColor: ColorPalette.gtBlue.uiColor,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: true
        )
        
        navigationController.setViewControllers([getOnboardingTutorialView()], animated: false)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .videoButtonTappedFromOnboardingTutorial(let youtubeVideoId):
            presentVideoPlayerView(youtubeVideoId: youtubeVideoId)
        
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
    
    private func presentVideoPlayerView(youtubeVideoId: String) {
        
        let viewModel = FullScreenVideoViewModel(
            flowDelegate: self,
            videoId: youtubeVideoId,
            videoPlayerParameters: nil,
            userDidCloseVideoStep: .closeVideoPlayerTappedFromOnboardingTutorial,
            videoEndedStep: .videoEndedOnOnboardingTutorial
        )
        
        presentVideoModal(viewModel: viewModel)
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
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            onboardingTutorialViewedRepository: appDiContainer.dataLayer.getOnboardingTutorialViewedRepository(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            analyticsContainer: appDiContainer.dataLayer.getAnalytics(),
            trackTutorialVideoAnalytics: appDiContainer.getTutorialVideoAnalytics()
        )
        
        let view = OnboardingTutorialView(viewModel: viewModel)
        
        let hostingView = UIHostingController<OnboardingTutorialView>(rootView: view)
        
        var skipButton: UIBarButtonItem?
        
        viewModel.hidesSkipButton
            .receiveOnMain()
            .sink { (hidden: Bool) in
                
                let skipButtonPosition: BarButtonItemBarPosition = .right
                
                if skipButton == nil, !hidden {
                    
                    skipButton = hostingView.addBarButtonItem(
                        to: skipButtonPosition,
                        title: viewModel.skipButtonTitle,
                        style: .plain,
                        color: ColorPalette.gtBlue.uiColor,
                        target: viewModel,
                        action: #selector(viewModel.skipTapped)
                    )
                }
                else if let skipButton = skipButton {
                    
                    hidden ? hostingView.removeBarButtonItem(item: skipButton) : hostingView.addBarButtonItem(item: skipButton, barPosition: skipButtonPosition)
                }
            }
            .store(in: &cancellables)
        
        return hostingView
    }
    
    private func getOnboardingQuickStartView() -> UIViewController {
        
        let viewModel = OnboardingQuickStartViewModel(
            flowDelegate: self,
            localizationServices: appDiContainer.localizationServices,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            getOnboardingQuickStartItemsUseCase: appDiContainer.domainLayer.getOnboardingQuickStartItemsUseCase(),
            trackActionAnalytics: appDiContainer.dataLayer.getAnalytics().trackActionAnalytics
        )
        
        let view = OnboardingQuickStartView(viewModel: viewModel)
        
        let hostingView = UIHostingController<OnboardingQuickStartView>(rootView: view)
        
        _ = hostingView.addBarButtonItem(
            to: .right,
            title: viewModel.skipButtonTitle,
            style: .plain,
            color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
            target: viewModel,
            action: #selector(viewModel.skipTapped)
        )
        
        return hostingView
    }
}
