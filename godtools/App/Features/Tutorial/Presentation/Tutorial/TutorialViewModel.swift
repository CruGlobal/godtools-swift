//
//  TutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class TutorialViewModel: ObservableObject {
        
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getTutorialUseCase: GetTutorialUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var interfaceStrings: TutorialInterfaceStringsDomainModel?
    
    @Published var hidesBackButton: Bool = true
    @Published var tutorialPages: [TutorialPageDomainModel] = Array()
    @Published var continueTitle: String = ""
    @Published var currentPage: Int = 0
        
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getTutorialUseCase: GetTutorialUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, tutorialVideoAnalytics: TutorialVideoAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getTutorialUseCase = getTutorialUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
                
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<TutorialDomainModel, Never> in
                
                return getTutorialUseCase
                    .getTutorialPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (tutorial: TutorialDomainModel) in
                
                self?.interfaceStrings = tutorial.interfaceStrings
                self?.tutorialPages = tutorial.pages
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $currentPage.eraseToAnyPublisher(),
            $interfaceStrings.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (currentPage: Int, interfaceStrings: TutorialInterfaceStringsDomainModel?) in
            if let interfaceStrings = interfaceStrings {
                self?.refreshContinueTitle(interfaceStrings: interfaceStrings)
            }
        }
        .store(in: &cancellables)
        
        $currentPage
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (page: Int) in
                self?.pageDidChange(page: page)
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
    
    private var isOnLastPage: Bool {
        
        guard tutorialPages.count > 0 else {
            return false
        }
        
        return currentPage >= tutorialPages.count - 1
    }
    
    private func pageDidChange(page: Int) {
                
        hidesBackButton = isOnFirstPage
                                
        let analyticsScreenName = getAnalyticsScreenName(tutorialItemIndex: page)
        let analyticsSiteSection = analyticsSiteSection
        let analyticsSiteSubSection = analyticsSiteSubsection
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: nil
        )
    }
    
    private func refreshContinueTitle(interfaceStrings: TutorialInterfaceStringsDomainModel) {
        continueTitle = isOnLastPage ? interfaceStrings.completeTutorialActionTitle : interfaceStrings.nextTutorialPageActionTitle
    }
}

// MARK: - Inputs

extension TutorialViewModel {
    
    @objc func backTapped() {
        flowDelegate?.navigate(step: .backTappedFromTutorial)
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
                contentLanguage: nil,
                secondaryContentLanguage: nil
            )
        }
    }
    
    func continueTapped() {
        
        if isOnLastPage {
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
        }
        else {
            currentPage = currentPage + 1
        }
    }
}
