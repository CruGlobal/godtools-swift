//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class OnboardingTutorialViewModel: ObservableObject {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository
    private let localizationServices: LocalizationServices
    private let analyticsContainer: AnalyticsContainer
    private let trackTutorialVideoAnalytics: TutorialVideoAnalytics
    private let readyForEveryConversationYoutubeVideoId: String = "RvhZ_wuxAgE"
    
    private weak var flowDelegate: FlowDelegate?
    
    let hidesSkipButton: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    
    @Published var currentPage: Int = 0 {
        didSet {
            didSetPage(page: currentPage)
        }
    }
    
    @Published var pages: [OnboardingTutorialPage] = [.readyForEveryConversation, .talkAboutGodWithAnyone, .prepareForTheMomentsThatMatter, .helpSomeoneDiscoverJesus]
    @Published var skipButtonTitle: String
    @Published var continueButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository, localizationServices: LocalizationServices, analyticsContainer: AnalyticsContainer, trackTutorialVideoAnalytics: TutorialVideoAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
        self.localizationServices = localizationServices
        self.analyticsContainer = analyticsContainer
        self.trackTutorialVideoAnalytics = trackTutorialVideoAnalytics
        
        skipButtonTitle = localizationServices.stringForMainBundle(key: "navigationBar.navigationItem.skip")
        
        onboardingTutorialViewedRepository.storeOnboardingTutorialViewed(viewed: true)
        
        didSetPage(page: currentPage)
    }
    
    private func getOnboardingTutorialPageAnalyticsProperties(page: OnboardingTutorialPage) -> OnboardingTutorialPageAnalyticsProperties {
        
        let pageOffset: Int = 2
        let pageIndex: Int = pages.firstIndex(of: page) ?? -1
        
        return OnboardingTutorialPageAnalyticsProperties(
            screenName: "onboarding" + "-" + String(pageIndex + pageOffset),
            siteSection: "onboarding",
            siteSubsection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage ?? "",
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage ?? ""
        )
    }
    
    private func didSetPage(page: Int) {
        
        switch page {
        
        case 0:
            hidesSkipButton.send(true)
            continueButtonTitle = localizationServices.stringForMainBundle(key: "onboardingTutorial.beginButton.title")
       
        default:
            hidesSkipButton.send(false)
            continueButtonTitle = localizationServices.stringForMainBundle(key: "onboardingTutorial.nextButton.title")
        }
        
        
        let pageAnalytics = getOnboardingTutorialPageAnalyticsProperties(page: pages[page])
        
        let trackScreen = TrackScreenModel(
            screenName: pageAnalytics.screenName,
            siteSection: pageAnalytics.siteSection,
            siteSubSection: pageAnalytics.siteSubsection,
            contentLanguage: pageAnalytics.contentLanguage,
            secondaryContentLanguage: pageAnalytics.secondaryContentLanguage
        )
        
        analyticsContainer.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
    }
    
    func getOnboardingTutorialReadyForEveryConversationViewModel() -> OnboardingTutorialReadyForEveryConversationViewModel {
        
        return OnboardingTutorialReadyForEveryConversationViewModel(
            title: localizationServices.stringForMainBundle(key: "onboardingTutorial.0.title"),
            watchVideoButtonTitle: localizationServices.stringForMainBundle(key: "onboardingTutorial.0.videoLink.title")
        )
    }
    
    func getOnboardingTutorialPrepareForTheMomentsThatMatterViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: localizationServices.stringForMainBundle(key: "onboardingTutorial.2.title"),
            message: localizationServices.stringForMainBundle(key: "onboardingTutorial.2.message"),
            animationFilename: "onboarding_prepare_for_moments"
        )
    }
    
    func getOnboardingTutorialTalkAboutGodWithAnyoneViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: localizationServices.stringForMainBundle(key: "onboardingTutorial.1.title"),
            message: localizationServices.stringForMainBundle(key: "onboardingTutorial.1.message"),
            animationFilename: "onboarding_talk_about_god"
        )
    }
    
    func getOnboardingTutorialHelpSomeoneDiscoverJesusViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: localizationServices.stringForMainBundle(key: "onboardingTutorial.3.title"),
            message: localizationServices.stringForMainBundle(key: "onboardingTutorial.3.message"),
            animationFilename: "onboarding_help_someone_discover_jesus"
        )
    }
}

// MARK: - Inputs

extension OnboardingTutorialViewModel {
    
    @objc func skipTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingTutorial)
    }
    
    func continueTapped() {
        
        let lastPage: Int = pages.count - 1
        
        let reachedEnd = currentPage >= lastPage
        
        if reachedEnd {
            
            flowDelegate?.navigate(step: .endTutorialFromOnboardingTutorial)
            
            let pageAnalytics = getOnboardingTutorialPageAnalyticsProperties(page: pages[currentPage])
            
            let trackAction = TrackActionModel(
                screenName: pageAnalytics.screenName,
                actionName: "Onboarding Start",
                siteSection: pageAnalytics.siteSection,
                siteSubSection: pageAnalytics.siteSubsection,
                contentLanguage: pageAnalytics.contentLanguage,
                secondaryContentLanguage: pageAnalytics.secondaryContentLanguage,
                url: nil,
                data: [AnalyticsConstants.Keys.onboardingStart: 1]
            )
            
            analyticsContainer.trackActionAnalytics.trackAction(trackAction: trackAction)
        }
        else {
            
            currentPage += 1
        }
    }
    
    func watchReadyForEveryConversationVideoTapped() {
        
        flowDelegate?.navigate(step: .videoButtonTappedFromOnboardingTutorial(youtubeVideoId: readyForEveryConversationYoutubeVideoId))
        
        let pageAnalytics = getOnboardingTutorialPageAnalyticsProperties(page: .readyForEveryConversation)
        
        trackTutorialVideoAnalytics.trackVideoPlayed(
            videoId: readyForEveryConversationYoutubeVideoId,
            screenName: pageAnalytics.screenName,
            contentLanguage: pageAnalytics.contentLanguage,
            secondaryContentLanguage: pageAnalytics.secondaryContentLanguage
        )
    }
}
