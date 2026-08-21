//
//  TutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class TutorialViewModel: ObservableObject {
        
    private let stepEmitter: FlowStepEmitter
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getTutorialStringsUseCase: GetTutorialStringsUseCase
    private let getTutorialUseCase: GetTutorialUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    @Published private var strings: TutorialStringsDomainModel?
    
    @Published private(set) var hidesBackButton: Bool = true
    @Published private(set) var tutorialPages: [TutorialPageDomainModel] = Array()
    @Published private(set) var continueTitle: String = ""
    
    @Published var currentPage: Int = 0
        
    init(
        stepEmitter: FlowStepEmitter,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getTutorialStringsUseCase: GetTutorialStringsUseCase,
        getTutorialUseCase: GetTutorialUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase,
        tutorialVideoAnalytics: TutorialVideoAnalytics
    ) {
        
        self.stepEmitter = stepEmitter
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getTutorialStringsUseCase = getTutorialStringsUseCase
        self.getTutorialUseCase = getTutorialUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
                
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
    
    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getTutorialStringsUseCase.execute(appLanguage: appLanguage)

        tutorialPages = getTutorialUseCase.execute(appLanguage: appLanguage).pages
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
        let analyticsProperties = AnalyticsProperties(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubsection,
            appLanguage: nil,
            contentLanguage: nil,
            secondaryContentLanguage: nil
        )
        let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase = self.trackScreenViewAnalyticsUseCase
        let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase = self.trackActionAnalyticsUseCase
        
        Task.detached {
            await trackScreenViewAnalyticsUseCase.execute(
                properties: analyticsProperties
            )
        }
        
        Task.detached {
            await trackActionAnalyticsUseCase.execute(
                properties: analyticsProperties,
                actionName: analyticsScreenName,
                data: nil
            )
        }
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
        stepEmitter.emit(step: AppFlowStep.closeTappedFromTutorial)
    }
    
    func tutorialVideoPlayTapped(tutorialPageIndex: Int) {
        
        let tutorialPage: TutorialPageDomainModel = tutorialPages[tutorialPageIndex]
        
        guard let videoId = tutorialPage.getVideoId(), !videoId.isEmpty else {
            return
        }
        
        let youTubeVideoTracked: Bool = trackedAnalyticsForYouTubeVideoIds.contains(videoId)
        
        if !youTubeVideoTracked {
            
            trackedAnalyticsForYouTubeVideoIds.append(videoId)
                        
            let analyticsProperties = AnalyticsProperties(
                screenName: getAnalyticsScreenName(tutorialItemIndex: tutorialPageIndex),
                siteSection: "",
                siteSubSection: "",
                appLanguage: appLanguage,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            )
            let tutorialVideoAnalytics: TutorialVideoAnalytics = self.tutorialVideoAnalytics
            
            Task.detached {
                
                await tutorialVideoAnalytics.trackVideoPlayed(
                    videoId: videoId,
                    properties: analyticsProperties
                )
            }
        }
    }
    
    func continueTapped() {

        stepEmitter.emit(step: AppFlowStep.continueTappedFromTutorial)
    }
}
