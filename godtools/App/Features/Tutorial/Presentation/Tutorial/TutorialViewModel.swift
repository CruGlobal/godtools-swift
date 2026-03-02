//
//  TutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class TutorialViewModel: ObservableObject {
        
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getTutorialStringsUseCase: GetTutorialStringsUseCase
    private let getTutorialUseCase: GetTutorialUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var strings: TutorialStringsDomainModel?
    
    @Published private(set) var hidesBackButton: Bool = true
    @Published private(set) var tutorialPages: [TutorialPageDomainModel] = Array()
    @Published private(set) var continueTitle: String = ""
    
    @Published var currentPage: Int = 0
        
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getTutorialStringsUseCase: GetTutorialStringsUseCase, getTutorialUseCase: GetTutorialUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, tutorialVideoAnalytics: TutorialVideoAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getTutorialStringsUseCase = getTutorialStringsUseCase
        self.getTutorialUseCase = getTutorialUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
                
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getTutorialStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: TutorialStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getTutorialUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (tutorial: TutorialDomainModel) in
                
                self?.tutorialPages = tutorial.pages
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3(
            $currentPage,
            $strings,
            $tutorialPages.dropFirst()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (currentPage: Int, strings: TutorialStringsDomainModel?, tutorialPages: [TutorialPageDomainModel]) in
            
            if let strings = strings {
                self?.refreshContinueTitle(strings: strings, tutorialPages: tutorialPages)
            }
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $currentPage,
            $tutorialPages.dropFirst()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (page: Int, tutorialPages: [TutorialPageDomainModel]) in
            self?.pageDidChange(page: page, tutorialPages: tutorialPages)
        }
        .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func getAnalyticsScreenName(tutorialItemIndex: Int) -> String {
        return "tutorial-\(tutorialItemIndex + 1)"
    }
    
    private var analyticsSiteSection: String {
        return "tutorial"
    }
    
    private var analyticsSiteSubsection: String {
        return ""
    }
    
    private var isOnFirstPage: Bool {
        return currentPage == 0
    }
    
    private func getIsOnLastPage(tutorialPages: [TutorialPageDomainModel]) -> Bool {
        
        guard tutorialPages.count > 0 else {
            return false
        }
        
        return currentPage >= tutorialPages.count - 1
    }
    
    private func pageDidChange(page: Int, tutorialPages: [TutorialPageDomainModel]) {
                
        hidesBackButton = isOnFirstPage
                                
        let analyticsScreenName = getAnalyticsScreenName(tutorialItemIndex: page)
        let analyticsSiteSection = analyticsSiteSection
        let analyticsSiteSubSection = analyticsSiteSubsection
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: nil
        )
    }
    
    private func refreshContinueTitle(strings: TutorialStringsDomainModel, tutorialPages: [TutorialPageDomainModel]) {
        
        let isOnLastPage: Bool = getIsOnLastPage(tutorialPages: tutorialPages)
        
        continueTitle = isOnLastPage ? strings.completeTutorialActionTitle : strings.nextTutorialPageActionTitle
    }
}

// MARK: - Inputs

extension TutorialViewModel {
    
    @objc func backTapped() {
        
        if !isOnFirstPage {
            currentPage -= 1
        }
    }
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromTutorial)
    }
    
    func tutorialVideoPlayTapped(tutorialPageIndex: Int) {
        
        let tutorialPage: TutorialPageDomainModel = tutorialPages[tutorialPageIndex]
        
        guard let videoId = tutorialPage.getVideoId(), !videoId.isEmpty else {
            return
        }
        
        let youTubeVideoTracked: Bool = trackedAnalyticsForYouTubeVideoIds.contains(videoId)
        
        if !youTubeVideoTracked {
            
            trackedAnalyticsForYouTubeVideoIds.append(videoId)
            
            tutorialVideoAnalytics.trackVideoPlayed(
                videoId: videoId,
                screenName: getAnalyticsScreenName(tutorialItemIndex: tutorialPageIndex),
                appLanguage: appLanguage,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            )
        }
    }
    
    func continueTapped() {
        
        let isOnLastPage: Bool = getIsOnLastPage(tutorialPages: tutorialPages)
        
        if isOnLastPage {
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
        }
        else {
            currentPage += 1
        }
    }
}
