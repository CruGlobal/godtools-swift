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

final class OnboardingFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case completed
    }
        
    @Published private var currentAppLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    private var didPromptForAppLanguage: Bool = false
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(appDiContainer: AppDiContainer) {
                
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: OnboardingFlow.getOnboardingTutorial(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter
            ),
            stepEmitter: stepEmitter,
            navigationController: AppNavigationController(
                navigationBarAppearance: AppNavigationBarAppearance(
                    backgroundColor: .clear,
                    controlColor: ColorPalette.gtBlue.uiColor,
                    titleFont: nil,
                    titleColor: nil,
                    isTranslucent: true
                )
            )
        )
        
        navigationController.modalPresentationStyle = .fullScreen
                        
        appDiContainer.feature.appLanguage
            .domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentAppLanguage)
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }
        
        switch appStep {
            
        case .chooseAppLanguageTappedFromOnboardingTutorial:
            pushFlow(
                flow: ChooseAppLanguageFlow(appDiContainer: appDiContainer),
                animated: true
            )
            
        case .chooseAppLanguageFlowCompleted(let state):
            
            switch state {
            
            case .userClosedChooseAppLanguage:
                popFlow()
            
            case .userChoseAppLanguage( _):
                
                guard GodToolsApp.showsPersonalization else {
                    removeAllFlows()
                    if let tutorialVC = onboardingTutorialViewController {
                        navigationController.popToViewController(tutorialVC, animated: true)
                    }
                    return
                }
                
                pushFlow(
                    flow: LocalizationSettingsFlow(
                        appDiContainer: appDiContainer,
                        shouldStoreCountryWhenSelected: false
                    )
                )
            }
            
        case .localizationSettingsFlowCompleted(let state):
            
            switch state {
                
            case .userTappedBackFromLocalizationSettings:
                popFlow()
                
            case .userConfirmedLocalizationSetting( _):
                
                removeAllFlows()

                if let tutorialVC = onboardingTutorialViewController {
                    navigationController.popToViewController(tutorialVC, animated: true)
                }
            }
            
        case .videoButtonTappedFromOnboardingTutorial(let youtubeVideoId):
            presentWatchOnboardingTutorialVideoPlayer(youtubeVideoId: youtubeVideoId)
        
        case .closeVideoPlayerTappedFromOnboardingTutorial:
            dismissVideoModal(animated: true, completion: nil)
            
        case .videoEndedOnOnboardingTutorial:
            dismissVideoModal(animated: true, completion: nil)
            
        case .skipTappedFromOnboardingTutorial:
            completeFlow(state: .completed)
            
        case .continueTappedFromTutorial:
            
            guard let onboardingTutorialView = self.onboardingTutorialView else {
                return
            }
            
            let page: OnboardingTutorialPage? = onboardingTutorialView.getCurrentPage()
            let lastPage: Int = onboardingTutorialView.getPageCount() - 1
            let currentPage: Int = onboardingTutorialView.getCurrentPageIndex()
            let reachedEnd = currentPage >= lastPage
            
            if !GodToolsApp.showsPersonalization {
                didPromptForAppLanguage = true
            }
            
            if reachedEnd {
                
                navigate(step: AppFlowStep.endTutorialFromOnboardingTutorial)
                
                if let page = page {
                    
                    let pageAnalytics: OnboardingTutorialPageAnalyticsProperties = onboardingTutorialView.getOnboardingTutorialPageAnalyticsProperties(
                        page: page
                    )
                    
                    appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase().trackAction(
                        screenName: pageAnalytics.screenName,
                        actionName: "Onboarding Start",
                        siteSection: pageAnalytics.siteSection,
                        siteSubSection: pageAnalytics.siteSubsection,
                        appLanguage: nil,
                        contentLanguage: pageAnalytics.contentLanguage,
                        contentLanguageSecondary: pageAnalytics.contentLanguageSecondary,
                        url: nil,
                        data: [AnalyticsConstants.Keys.onboardingStart: 1]
                    )
                }
            }
            else if !reachedEnd && !didPromptForAppLanguage {
                
                didPromptForAppLanguage = true
                
                pushFlow(
                    flow: ChooseAppLanguageFlow(appDiContainer: appDiContainer),
                    animated: true
                )
            }
            else {
                
                onboardingTutorialView.setCurrentPage(page: currentPage + 1)
            }
            
        case .endTutorialFromOnboardingTutorial:
            completeFlow(state: .completed)
        
        default:
            break
        }
    }
    
    private func presentWatchOnboardingTutorialVideoPlayer(youtubeVideoId: String) {
        
        let videoPlayerParameters: [String: Any] = [
            YoutubePlayerParameters.interfaceLanguage.rawValue: currentAppLanguage
        ]
        
        let viewModel = FullScreenVideoViewModel(
            stepEmitter: stepEmitter,
            videoId: youtubeVideoId,
            videoPlayerParameters: videoPlayerParameters,
            userDidCloseVideoStep: AppFlowStep.closeVideoPlayerTappedFromOnboardingTutorial,
            videoEndedStep: AppFlowStep.videoEndedOnOnboardingTutorial
        )
        
        presentVideoModal(
            viewModel: viewModel,
            screenAccessibility: .watchOnboardingTutorialVideo
        )
    }
    
    private func completeFlow(state: OnboardingFlow.CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.onboardingFlowCompleted(state: state))
    }
}

// MARK: -

extension OnboardingFlow {
    
    private var onboardingTutorialView: OnboardingTutorialView? {

        return onboardingTutorialViewController?.rootView
    }

    private var onboardingTutorialViewController: AppHostingController<OnboardingTutorialView>? {
        
        for viewController in navigationController.viewControllers {
            if let hosting = viewController as? AppHostingController<OnboardingTutorialView> {
                return hosting
            }
        }
        
        return nil
    }
}

extension OnboardingFlow {
    
    private static func getOnboardingTutorial(appDiContainer: AppDiContainer, stepEmitter: FlowStepEmitter) -> UIViewController {
        
        let viewModel = OnboardingTutorialViewModel(
            stepEmitter: stepEmitter,
            viewedOnboardingTutorialUseCase: appDiContainer.feature.onboarding.domainLayer.getViewedOnboardingTutorialUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getOnboardingTutorialStringsUseCase: appDiContainer.feature.onboarding.domainLayer.getOnboardingTutorialStringsUseCase(),
            trackTutorialVideoAnalytics: appDiContainer.core.dataLayer.getTutorialVideoAnalytics(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
        )
                
        let view = OnboardingTutorialView(viewModel: viewModel)
        
        let skipButton = AppSkipBarItem(
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            localizationServices: appDiContainer.core.dataLayer.getLocalizationServices(),
            target: viewModel,
            action: #selector(viewModel.skipTapped),
            accessibilityIdentifier: AccessibilityStrings.Button.skip.id,
            hidesBarItemPublisher: viewModel.$hidesSkipButton.eraseToAnyPublisher()
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
}
