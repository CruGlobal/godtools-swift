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
        
    private let getTutorialUseCase: GetTutorialUseCase
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    private let hidesBackButtonSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    private var tutorialDomainModel: TutorialDomainModel? = nil {
        didSet {
            numberOfPages = tutorialDomainModel?.tutorialItems.count ?? 0
        }
    }
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var numberOfPages: Int = 0
    @Published var continueTitle: String = ""
    @Published var currentPage: Int = 0 {
        didSet {
            currentPageDidChange(page: currentPage)
        }
    }
    
    let hidesBackButton: ObservableValue<Bool> = ObservableValue(value: false)
    
    init(flowDelegate: FlowDelegate, getTutorialUseCase: GetTutorialUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer, tutorialVideoAnalytics: TutorialVideoAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.getTutorialUseCase = getTutorialUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
                
        getTutorialUseCase.getTutorialPublisher()
            .sink { [weak self] (tutorialDomainModel: TutorialDomainModel) in
                
                self?.tutorialDomainModel = tutorialDomainModel
                self?.currentPageDidChange(page: 0)
            }
            .store(in: &cancellables)
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
    
    private var tutorialItems: [TutorialItemDomainModel] {
        return tutorialDomainModel?.tutorialItems ?? []
    }
    
    private var isOnFirstPage: Bool {
        return currentPage == 0
    }
    
    private var isOnLastPage: Bool {
        
        guard numberOfPages > 0 else {
            return false
        }
        
        return currentPage >= numberOfPages - 1
    }
    
    private func currentPageDidChange(page: Int) {
                
        hidesBackButtonSubject.send(isOnFirstPage)
                                
        let analyticsScreenName = getAnalyticsScreenName(tutorialItemIndex: page)
        let analyticsSiteSection = analyticsSiteSection
        let analyticsSiteSubSection = analyticsSiteSubsection
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
                
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: nil
        )
        
        if isOnFirstPage {
            analytics.appsFlyerAnalytics.trackAction(actionName: trackAction.actionName, data: trackAction.data)
        }
        else if isOnLastPage {
            analytics.appsFlyerAnalytics.trackAction(actionName: trackAction.actionName, data: trackAction.data)
        }
        
        if isOnLastPage {
            continueTitle = tutorialDomainModel?.lastPageContinueButtonTitle ?? ""
        }
        else {
            continueTitle = tutorialDomainModel?.defaultContinueButtonTitle ?? ""
        }
    }
    
    var hidesBackButtonPublisher: AnyPublisher<Bool, Never> {
        return hidesBackButtonSubject
            .eraseToAnyPublisher()
    }
}

// MARK: - Inputs

extension TutorialViewModel {
    
    func tutorialPageWillAppear(tutorialItemIndex: Int) -> TutorialItemViewModel {
        
        return TutorialItemViewModel(
            tutorialItem: tutorialItems[tutorialItemIndex]
        )
    }
    
    @objc func backTapped() {
        
        if !isOnFirstPage {
            currentPage = currentPage - 1
        }
    }
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromTutorial)
    }
    
    func tutorialVideoPlayTapped(tutorialItemIndex: Int) {
          
        let tutorialItem: TutorialItemDomainModel = tutorialItems[tutorialItemIndex]
        
        guard let videoId = tutorialItem.youTubeVideoId, !videoId.isEmpty else {
            return
        }
        
        let youTubeVideoTracked: Bool = trackedAnalyticsForYouTubeVideoIds.contains(videoId)
        
        if !youTubeVideoTracked {
            
            trackedAnalyticsForYouTubeVideoIds.append(videoId)
            
            tutorialVideoAnalytics.trackVideoPlayed(
                videoId: videoId,
                screenName: getAnalyticsScreenName(tutorialItemIndex: tutorialItemIndex),
                contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
                secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
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
