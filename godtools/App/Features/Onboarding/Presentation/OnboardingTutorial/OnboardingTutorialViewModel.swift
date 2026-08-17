//
//  OnboardingTutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class OnboardingTutorialViewModel: ObservableObject {
    
    private static let continueButtonContinueAccessibility: AccessibilityStrings.Button = .continueForward
        
    private let stepEmitter: FlowStepEmitter
    private let viewedOnboardingTutorialUseCase: ViewedOnboardingTutorialUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getOnboardingTutorialStringsUseCase: GetOnboardingTutorialStringsUseCase
    private let trackTutorialVideoAnalytics: TutorialVideoAnalytics
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let readyForEveryConversationYoutubeVideoId: String = "RvhZ_wuxAgE"
    private let showsChooseAppLanguageButtonOnPages: [Int] = [0]
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage = AppLanguageDomainModel.english
    
    @Published private(set) var strings = OnboardingTutorialStringsDomainModel.emptyValue
    @Published private(set) var continueButtonAccessibility: AccessibilityStrings.Button = OnboardingTutorialViewModel.continueButtonContinueAccessibility
    @Published private(set) var hidesSkipButton: Bool = true
    @Published private(set) var showsChooseLanguageButton: Bool = true
    @Published private(set) var pages: [OnboardingTutorialPage] = [.readyForEveryConversation, .talkAboutGodWithAnyone, .prepareForTheMomentsThatMatter, .helpSomeoneDiscoverJesus]
    @Published private(set) var continueButtonTitle: String = ""
    
    @Published var currentPage: Int = 0
    
    init(
        stepEmitter: FlowStepEmitter,
        viewedOnboardingTutorialUseCase: ViewedOnboardingTutorialUseCase,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getOnboardingTutorialStringsUseCase: GetOnboardingTutorialStringsUseCase,
        trackTutorialVideoAnalytics: TutorialVideoAnalytics,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.viewedOnboardingTutorialUseCase = viewedOnboardingTutorialUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getOnboardingTutorialStringsUseCase = getOnboardingTutorialStringsUseCase
        self.trackTutorialVideoAnalytics = trackTutorialVideoAnalytics
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        Task {
            
            await viewedOnboardingTutorialUseCase
                .execute()
        }
                
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $currentPage,
            $pages,
            $strings
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (
            currentPage: Int,
            pages: [OnboardingTutorialPage],
            strings: OnboardingTutorialStringsDomainModel
        ) in
            
            self?.didSetPage(page: currentPage, pages: pages, strings: strings)
        }
        .store(in: &cancellables)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.updateShowsChooseLanguageButtonState(page: weakSelf.currentPage)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        Task {

            strings = await getOnboardingTutorialStringsUseCase.execute(appLanguage: appLanguage)
        }
    }
    
    private func updateShowsChooseLanguageButtonState(page: Int) {
        showsChooseLanguageButton = showsChooseAppLanguageButtonOnPages.contains(page)
    }
    
    private func didSetPage(page: Int, pages: [OnboardingTutorialPage], strings: OnboardingTutorialStringsDomainModel) {
                
        updateShowsChooseLanguageButtonState(page: page)
        
        let isFirstPage: Bool = page == 0
        let isLastPage: Bool = pages.count > 0 && page == pages.count - 1
        
        let hidesSkipButton: Bool
        let continueButtonTitle: String
        let continueButtonAccessibility: AccessibilityStrings.Button
                
        if isFirstPage {
            
            hidesSkipButton = true
            continueButtonTitle = strings.beginTutorialButtonTitle
            continueButtonAccessibility = Self.continueButtonContinueAccessibility
        }
        else if isLastPage {
            
            hidesSkipButton = true
            continueButtonTitle = strings.endTutorialButtonTitle
            continueButtonAccessibility = .getStarted
        }
        else {
         
            hidesSkipButton = false
            continueButtonTitle = strings.nextTutorialPageButtonTitle
            continueButtonAccessibility = Self.continueButtonContinueAccessibility
        }
        
        self.hidesSkipButton = hidesSkipButton
        self.continueButtonTitle = continueButtonTitle
        self.continueButtonAccessibility = continueButtonAccessibility
        
        if page >= 0 && page < pages.count {
         
            let properties = getOnboardingTutorialPageAnalyticsProperties(page: pages[page])
            
            Task {
                
                await trackScreenViewAnalyticsUseCase.execute(
                    properties: properties
                )
            }
        }
        else {
            
            assertionFailure("Failed to fetch page at index:\n  \(page)\n  pages: \(pages)")
        }
    }
    
    func getPage(index: Int) -> OnboardingTutorialPage? {
        return pages[safe: index]
    }
    
    func getOnboardingTutorialPageAnalyticsProperties(page: OnboardingTutorialPage) -> AnalyticsProperties {
        
        let pageOffset: Int = 2
        let pageIndex: Int = pages.firstIndex(of: page) ?? -1
        
        return AnalyticsProperties(
            screenName: "onboarding" + "-" + String(pageIndex + pageOffset),
            siteSection: "onboarding",
            siteSubSection: "",
            appLanguage: appLanguage,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
    }
    
    func getOnboardingTutorialReadyForEveryConversationViewModel() -> OnboardingTutorialReadyForEveryConversationViewModel {
        
        return OnboardingTutorialReadyForEveryConversationViewModel(
            title: strings.readyForEveryConversationTitle,
            watchVideoButtonTitle: strings.readyForEveryConversationVideoLinkTitle
        )
    }
    
    func getOnboardingTutorialPrepareForTheMomentsThatMatterViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: strings.prepareForMomentsThatMatterTitle,
            message: strings.prepareForMomentsThatMatterMessage,
            animationFilename: "onboarding_prepare_for_moments"
        )
    }
    
    func getOnboardingTutorialTalkAboutGodWithAnyoneViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: strings.talkWithGodAboutAnyoneTitle,
            message: strings.talkWithGodAboutAnyoneMessage,
            animationFilename: "onboarding_talk_about_god"
        )
    }
    
    func getOnboardingTutorialHelpSomeoneDiscoverJesusViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: strings.helpSomeoneDiscoverJesusTitle,
            message: strings.helpSomeoneDiscoverJesusMessage,
            animationFilename: "onboarding_help_someone_discover_jesus"
        )
    }
}

// MARK: - Inputs

extension OnboardingTutorialViewModel {
    
    func chooseAppLanguageTapped() {
        
        stepEmitter.emit(step: AppFlowStep.chooseAppLanguageTappedFromOnboardingTutorial)
    }
    
    @objc func skipTapped() {
        
        stepEmitter.emit(step: AppFlowStep.skipTappedFromOnboardingTutorial)
        
        let properties = getOnboardingTutorialPageAnalyticsProperties(page: pages[currentPage])
        
        Task {
            await trackActionAnalyticsUseCase.execute(
                properties: properties,
                actionName: AnalyticsConstants.ActionNames.onboardingSkip,
                data: [AnalyticsConstants.Keys.onboardingSkip: 1]
            )
        }
    }
    
    func continueTapped() {
        
        stepEmitter.emit(step: AppFlowStep.continueTappedFromTutorial)
    }
    
    func watchReadyForEveryConversationVideoTapped() {
        
        stepEmitter.emit(step: AppFlowStep.videoButtonTappedFromOnboardingTutorial(youtubeVideoId: readyForEveryConversationYoutubeVideoId))
        
        let properties = getOnboardingTutorialPageAnalyticsProperties(page: .readyForEveryConversation)
        
        Task {
            
            await trackTutorialVideoAnalytics.trackVideoPlayed(
                videoId: readyForEveryConversationYoutubeVideoId,
                properties: properties
            )
        }
    }
}
