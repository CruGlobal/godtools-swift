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
    
    @Published private var currentAppLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    private var didPromptForAppLanguage: Bool = false
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
        
        getCurrentAppLanguageUseCase
            .execute()
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
            
            switch state {
            
            case .userClosedChooseAppLanguage:
                navigateBackFromChooseAppLanguageFlow()
            
            case .userChoseAppLanguage(let appLanguage):
                let localizationSettings = getLocalizationSettingsView()
                navigationController.pushViewController(localizationSettings, animated: true)
            }
            
        case .videoButtonTappedFromOnboardingTutorial(let youtubeVideoId):
            presentWatchOnboardingTutorialVideoPlayer(youtubeVideoId: youtubeVideoId)
        
        case .closeVideoPlayerTappedFromOnboardingTutorial:
            dismissVideoModal(animated: true, completion: nil)
            
        case .videoEndedOnOnboardingTutorial:
            dismissVideoModal(animated: true, completion: nil)
            
        case .skipTappedFromOnboardingTutorial:
            flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: nil))
            
        case .continueTappedFromTutorial:
            
            guard let onboardingTutorialView = self.onboardingTutorialView else {
                return
            }
            
            let page: OnboardingTutorialPage? = onboardingTutorialView.getCurrentPage()
            let lastPage: Int = onboardingTutorialView.getPageCount() - 1
            let currentPage: Int = onboardingTutorialView.getCurrentPageIndex()
            let reachedEnd = currentPage >= lastPage
            
            if reachedEnd {
                
                navigate(step: .endTutorialFromOnboardingTutorial)
                
                if let page = page {
                    
                    let pageAnalytics: OnboardingTutorialPageAnalyticsProperties = onboardingTutorialView.getOnboardingTutorialPageAnalyticsProperties(
                        page: page
                    )
                    
                    appDiContainer.domainLayer.getTrackActionAnalyticsUseCase().trackAction(
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
                
                navigateToChooseAppLanguageFlow()
            }
            else {
                
                onboardingTutorialView.setCurrentPage(page: currentPage + 1)
            }
            
        case .backTappedFromLocalizationSettings:
            navigationController.popViewController(animated: true)
            
        case .didSelectLocalizationFromLocalizationSettings(let localization):
            // TODO: Add confirmation popup. ~Levi
            // See Figma (https://www.figma.com/design/gdsgXh4cAeBAVrJzH7YoEOU6/GodTools-app-master-file?node-id=14999-2173&t=NLq4O0aCCH1N5Ou7-0)
            break
            
        case .endTutorialFromOnboardingTutorial:
            flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: nil))
        
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
        
        presentVideoModal(viewModel: viewModel, screenAccessibility: .watchOnboardingTutorialVideo)
    }
    
    private func completeOnboardingFlow(onboardingFlowCompletedState: OnboardingFlowCompletedState?) {
        
        flowDelegate?.navigate(step: .onboardingFlowCompleted(onboardingFlowCompletedState: onboardingFlowCompletedState))
    }
}

// MARK: -

extension OnboardingFlow {
    
    private var onboardingTutorialView: OnboardingTutorialView? {
        
        for viewController in navigationController.viewControllers {
            if let hosting = viewController as? AppHostingController<OnboardingTutorialView> {
                return hosting.rootView
            }
        }
        
        return nil
    }
    
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
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
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
