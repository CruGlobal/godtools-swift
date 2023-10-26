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
    
    private static let tutorialPages: [OnboardingTutorialPage] = [.readyForEveryConversation, .talkAboutGodWithAnyone, .prepareForTheMomentsThatMatter, .helpSomeoneDiscoverJesus]
    
    private static var trackInBackgroundViewedOnboardingTutorialCancellable: AnyCancellable?
    
    private let trackViewedOnboardingTutorialUseCase: TrackViewedOnboardingTutorialUseCase
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getOnboardingTutorialInterfaceStringsUseCase: GetOnboardingTutorialInterfaceStringsUseCase
    private let trackTutorialVideoAnalytics: TutorialVideoAnalytics
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let readyForEveryConversationYoutubeVideoId: String = "RvhZ_wuxAgE"
    private let hidesSkipButtonSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    private let showsChooseAppLanguageButtonOnPages: [Int] = [0]
    
    private var interfaceStrings: OnboardingTutorialInterfaceStringsDomainModel?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageCodeDomainModel = ""
    
    @Published var currentPage: Int = 0 {
        
        didSet {
            didSetPage(page: currentPage)
        }
    }
    
    @Published var chooseAppLanguageButtonTitle: String = ""
    @Published var showsChooseLanguageButton: Bool = true
    @Published var pages: [OnboardingTutorialPage] = Array()
    @Published var continueButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, trackViewedOnboardingTutorialUseCase: TrackViewedOnboardingTutorialUseCase, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getOnboardingTutorialInterfaceStringsUseCase: GetOnboardingTutorialInterfaceStringsUseCase, trackTutorialVideoAnalytics: TutorialVideoAnalytics, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.trackViewedOnboardingTutorialUseCase = trackViewedOnboardingTutorialUseCase
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getOnboardingTutorialInterfaceStringsUseCase = getOnboardingTutorialInterfaceStringsUseCase
        self.trackTutorialVideoAnalytics = trackTutorialVideoAnalytics
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
                        
        OnboardingTutorialViewModel.trackInBackgroundViewedOnboardingTutorialCancellable = trackViewedOnboardingTutorialUseCase
            .viewedPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (void: Void) in
                
            }
                
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        getOnboardingTutorialInterfaceStringsUseCase
            .getStringsPublisher(appLanguageCodeChangedPublisher: $appLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (interfaceStrings: OnboardingTutorialInterfaceStringsDomainModel) in
                
                guard let weakSelf = self else {
                    return
                }
                
                weakSelf.interfaceStrings = interfaceStrings
                
                weakSelf.chooseAppLanguageButtonTitle = interfaceStrings.chooseAppLanguageButtonTitle

                weakSelf.pages = OnboardingTutorialViewModel.tutorialPages
                
                let page: Int = weakSelf.currentPage
                weakSelf.currentPage = page
            }
            .store(in: &cancellables)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.updateShowsChooseLanguageButtonState(page: weakSelf.currentPage)
        }
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
    
    private func updateShowsChooseLanguageButtonState(page: Int) {
        showsChooseLanguageButton = showsChooseAppLanguageButtonOnPages.contains(page)
    }
    
    private func didSetPage(page: Int) {
                
        updateShowsChooseLanguageButtonState(page: page)
                
        switch page {
        
        case 0:
            hidesSkipButtonSubject.send(true)
            continueButtonTitle = interfaceStrings?.beginTutorialButtonTitle ?? ""
       
        default:
            hidesSkipButtonSubject.send(false)
            continueButtonTitle = interfaceStrings?.nextTutorialPageButtonTitle ?? ""
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
    
    var hidesSkipButtonPublisher: AnyPublisher<Bool, Never> {
        return hidesSkipButtonSubject
            .eraseToAnyPublisher()
    }
    
    func getOnboardingTutorialReadyForEveryConversationViewModel() -> OnboardingTutorialReadyForEveryConversationViewModel {
        
        return OnboardingTutorialReadyForEveryConversationViewModel(
            title: interfaceStrings?.readyForEveryConversationTitle ?? "",
            watchVideoButtonTitle: interfaceStrings?.readyForEveryConversationVideoLinkTitle ?? ""
        )
    }
    
    func getOnboardingTutorialPrepareForTheMomentsThatMatterViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: interfaceStrings?.prepareForMomentsThatMatterTitle ?? "",
            message: interfaceStrings?.prepareForMomentsThatMatterMessage ?? "",
            animationFilename: "onboarding_prepare_for_moments"
        )
    }
    
    func getOnboardingTutorialTalkAboutGodWithAnyoneViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: interfaceStrings?.talkWithGodAboutAnyoneTitle ?? "",
            message: interfaceStrings?.talkWithGodAboutAnyoneMessage ?? "",
            animationFilename: "onboarding_talk_about_god"
        )
    }
    
    func getOnboardingTutorialHelpSomeoneDiscoverJesusViewModel() -> OnboardingTutorialMediaViewModel {
        
        return OnboardingTutorialMediaViewModel(
            title: interfaceStrings?.helpSomeoneDiscoverJesusTitle ?? "",
            message: interfaceStrings?.helpSomeoneDiscoverJesusMessage ?? "",
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
