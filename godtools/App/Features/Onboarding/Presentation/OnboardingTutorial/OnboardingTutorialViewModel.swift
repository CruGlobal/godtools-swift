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
    
    private let onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository
    private let localizationServices: LocalizationServices
    private let trackTutorialVideoAnalytics: TutorialVideoAnalytics
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
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
    
    init(flowDelegate: FlowDelegate, onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository, localizationServices: LocalizationServices, trackTutorialVideoAnalytics: TutorialVideoAnalytics, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.onboardingTutorialViewedRepository = onboardingTutorialViewedRepository
        self.localizationServices = localizationServices
        self.trackTutorialVideoAnalytics = trackTutorialVideoAnalytics
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        skipButtonTitle = localizationServices.stringForSystemElseEnglish(key: "navigationBar.navigationItem.skip")
        
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
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
    
    private func didSetPage(page: Int) {
        
        switch page {
        
        case 0:
            hidesSkipButton.send(true)
            continueButtonTitle = localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.beginButton.title")
       
        default:
            hidesSkipButton.send(false)
            continueButtonTitle = localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.nextButton.title")
        }
        
        
        let pageAnalytics: OnboardingTutorialPageAnalyticsProperties = getOnboardingTutorialPageAnalyticsProperties(page: pages[page])
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: pageAnalytics.screenName,
            siteSection: pageAnalytics.siteSection,
            siteSubSection: pageAnalytics.siteSubsection,
            contentLanguage: pageAnalytics.contentLanguage,
            contentLanguageSecondary: pageAnalytics.contentLanguageSecondary
        )
    }
    
    func getOnboardingTutorialReadyForEveryConversationViewModel() -> OnboardingTutorialReadyForEveryConversationViewModel {
        
        return OnboardingTutorialReadyForEveryConversationViewModel(
            title: localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.0.title"),
            watchVideoButtonTitle: localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.0.videoLink.title")
        )
    }
    
    func getOnboardingTutorialPrepareForTheMomentsThatMatterViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.2.title"),
            message: localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.2.message"),
            animationFilename: "onboarding_prepare_for_moments"
        )
    }
    
    func getOnboardingTutorialTalkAboutGodWithAnyoneViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.1.title"),
            message: localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.1.message"),
            animationFilename: "onboarding_talk_about_god"
        )
    }
    
    func getOnboardingTutorialHelpSomeoneDiscoverJesusViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.3.title"),
            message: localizationServices.stringForSystemElseEnglish(key: "onboardingTutorial.3.message"),
            animationFilename: "onboarding_help_someone_discover_jesus"
        )
    }
}

// MARK: - Inputs

extension OnboardingTutorialViewModel {
    
    func chooseAppLanguageTapped() {
        
        flowDelegate?.navigate(step: .chooseAppLanguageTappedFromOnboardingTutorial)
    }
    
    @objc func skipTapped() {
        
        flowDelegate?.navigate(step: .skipTappedFromOnboardingTutorial)
    }
    
    func continueTapped() {
        
        let lastPage: Int = pages.count - 1
        
        let reachedEnd = currentPage >= lastPage
        
        if reachedEnd {
            
            flowDelegate?.navigate(step: .endTutorialFromOnboardingTutorial)
            
            let pageAnalytics: OnboardingTutorialPageAnalyticsProperties = getOnboardingTutorialPageAnalyticsProperties(page: pages[currentPage])
            
            trackActionAnalyticsUseCase.trackAction(
                screenName: pageAnalytics.screenName,
                actionName: "Onboarding Start",
                siteSection: pageAnalytics.siteSection,
                siteSubSection: pageAnalytics.siteSubsection,
                contentLanguage: pageAnalytics.contentLanguage,
                contentLanguageSecondary: pageAnalytics.contentLanguageSecondary,
                url: nil,
                data: [AnalyticsConstants.Keys.onboardingStart: 1]
            )
        }
        else {
            
            currentPage += 1
        }
    }
    
    func watchReadyForEveryConversationVideoTapped() {
        
        flowDelegate?.navigate(step: .videoButtonTappedFromOnboardingTutorial(youtubeVideoId: readyForEveryConversationYoutubeVideoId))
        
        let pageAnalytics: OnboardingTutorialPageAnalyticsProperties = getOnboardingTutorialPageAnalyticsProperties(page: .readyForEveryConversation)
        
        trackTutorialVideoAnalytics.trackVideoPlayed(
            videoId: readyForEveryConversationYoutubeVideoId,
            screenName: pageAnalytics.screenName,
            contentLanguage: pageAnalytics.contentLanguage,
            secondaryContentLanguage: pageAnalytics.contentLanguageSecondary
        )
    }
}
