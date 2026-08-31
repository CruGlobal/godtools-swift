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
import Flow

final class OnboardingFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case completed
    }
    
    private let onboardingSettings: OnboardingUserSettings
        
    @Published private var currentAppLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(appDiContainer: AppDiContainer) {
                
        let stepEmitter = FlowStepEmitter()
        
        let onboardingSettings = OnboardingUserSettings()
        
        self.onboardingSettings = onboardingSettings
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: OnboardingFlow.getOnboardingTutorial(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                onboardingSettings: onboardingSettings
            ),
            stepEmitter: stepEmitter,
            navigationController: AppNavigationController(
                navigationBarAppearance: AppNavigationBarAppearance(
                    backgroundColor: .clear,
                    controlColor: ColorPalette.gtBlue.uiColor,
                    titleFont: nil,
                    titleColor: ColorPalette.gtBlue.uiColor,
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
            
            case .userChoseAppLanguage(let appLanguage):
                
                onboardingSettings.setAppLanguage(appLanguage: appLanguage)
                
                guard GodToolsApp.showsPersonalization else {
                    removeAllFlows()
                    if let tutorialVC = onboardingTutorialViewController {
                        navigationController.popToViewController(tutorialVC, animated: true)
                    }
                    return
                }
                
                navigateToLocalizationSettings()
            }
            
        case .localizationSettingsFlowCompleted(let state):
            
            switch state {
                
            case .userTappedBackFromLocalizationSettings:
                popFlow()
                
            case .userConfirmedLocalizationSetting(let country):
                
                onboardingSettings.setCountry(country: country)
                
                if let onboardingTutorialView = self.onboardingTutorialView {
                    navigateToNextTutorialPage(onboardingTutorialView: onboardingTutorialView)
                }
                                
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
            
        case .continueTappedFromOnboardingTutorial:
            
            guard let onboardingTutorialView = self.onboardingTutorialView else {
                return
            }
            
            let reachedEnd: Bool = getReachedEndOfTutorial(onboardingTutorialView: onboardingTutorialView)
                        
            if reachedEnd {
                
                navigate(step: AppFlowStep.endTutorialFromOnboardingTutorial)
                
                trackOnboardingStartAnalytics(onboardingTutorialView: onboardingTutorialView)
            }
            else if !GodToolsApp.showsPersonalization {
                
                navigateToNextTutorialPage(onboardingTutorialView: onboardingTutorialView)
            }
            else {
                                
                if onboardingSettings.appLanguage == nil {
                    
                    pushFlow(
                        flow: ChooseAppLanguageFlow(appDiContainer: appDiContainer),
                        animated: true
                    )
                }
                else if onboardingSettings.country == nil {
                    
                    navigateToLocalizationSettings()
                }
                else {
                    
                    navigateToNextTutorialPage(onboardingTutorialView: onboardingTutorialView)
                }
            }
            
        case .endTutorialFromOnboardingTutorial:
            completeFlow(state: .completed)
        
        default:
            break
        }
    }
    
    private func getReachedEndOfTutorial(onboardingTutorialView: OnboardingTutorialView) -> Bool {
        
        let lastPage: Int = onboardingTutorialView.getPageCount() - 1
        let currentPage: Int = onboardingTutorialView.getCurrentPageIndex()
        let reachedEnd = currentPage >= lastPage
        
        return reachedEnd
    }
    
    private func navigateToNextTutorialPage(onboardingTutorialView: OnboardingTutorialView) {
        
        guard !getReachedEndOfTutorial(onboardingTutorialView: onboardingTutorialView) else {
            return
        }
        
        let currentPage: Int = onboardingTutorialView.getCurrentPageIndex()
        
        onboardingTutorialView.setCurrentPage(page: currentPage + 1)
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
    
    private func navigateToLocalizationSettings() {
        
        pushFlow(
            flow: LocalizationSettingsFlow(
                appDiContainer: appDiContainer,
                shouldStoreCountryWhenSelected: false
            )
        )
    }
    
    private func trackOnboardingStartAnalytics(onboardingTutorialView: OnboardingTutorialView) {
        
        guard let page = onboardingTutorialView.getCurrentPage() else {
            return
        }
        
        let trackActionAnalytics = appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
        
        let properties = onboardingTutorialView.getOnboardingTutorialPageAnalyticsProperties(
            page: page
        )
        
        Task.detached {
                                    
            await trackActionAnalytics.execute(
                properties: properties,
                actionName: AnalyticsConstants.ActionNames.onboardingStart,
                data: [AnalyticsConstants.Keys.onboardingStart: 1]
            )
        }
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
    
    private static func getOnboardingTutorial(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        onboardingSettings: OnboardingUserSettings
    ) -> UIViewController {
        
        let viewModel = OnboardingTutorialViewModel(
            stepEmitter: stepEmitter,
            viewedOnboardingTutorialUseCase: appDiContainer.feature.onboarding.domainLayer.getViewedOnboardingTutorialUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getOnboardingTutorialStringsUseCase: appDiContainer.feature.onboarding.domainLayer.getOnboardingTutorialStringsUseCase(),
            trackTutorialVideoAnalytics: appDiContainer.core.dataLayer.getTutorialVideoAnalytics(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase(),
            onboardingSettings: onboardingSettings
        )
                
        let view = OnboardingTutorialView(viewModel: viewModel)
        
        let hostingView = AppHostingController<OnboardingTutorialView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                titleView: InvisibleChooseAppLanguageButtonForNavigationBar(tappedClosure: {
                    viewModel.chooseAppLanguageTapped()
                })
            )
        )
        
        return hostingView
    }
}
