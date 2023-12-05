//
//  LessonsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class LessonsViewModel: ObservableObject {
        
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewLessonsUseCase: ViewLessonsUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let attachmentsRepository: AttachmentsRepository
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var didPullToRefresh: Void = ()
    
    @Published var sectionTitle: String = ""
    @Published var subtitle: String = ""
    @Published var lessons: [LessonListItemDomainModel] = []
    @Published var isLoadingLessons: Bool = true
        
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewLessonsUseCase: ViewLessonsUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewLessonsUseCase = viewLessonsUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.attachmentsRepository = attachmentsRepository
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        Publishers.CombineLatest(
            $appLanguage.eraseToAnyPublisher(),
            $didPullToRefresh.eraseToAnyPublisher()
        )
        .flatMap({ (appLanguage: AppLanguageDomainModel, didPullToRefresh: Void) -> AnyPublisher<ViewLessonsDomainModel, Never> in
            
            return self.viewLessonsUseCase
                .viewPublisher(appLanguage: appLanguage)
                .eraseToAnyPublisher()
        })
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (domainModel: ViewLessonsDomainModel) in
            
            self?.sectionTitle = domainModel.interfaceStrings.title
            self?.subtitle = domainModel.interfaceStrings.subtitle
            
            self?.lessons = domainModel.lessons
            self?.isLoadingLessons = false
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Analytics
    
    private var analyticsScreenName: String {
        return "Lessons"
    }
    
    private var analyticsSiteSection: String {
        return "home"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    private func trackPageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.viewedLessonsAction,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: nil
        )
    }
    
    private func trackLessonTappedAnalytics(lessonListItem: LessonListItemDomainModel) {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.lessonOpenTapped,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.lessons,
                AnalyticsConstants.Keys.tool: lessonListItem.analyticsToolName
            ]
        )
    }
}

// MARK: - Inputs

extension LessonsViewModel {
    
    func getLessonViewModel(lessonListItem: LessonListItemDomainModel) -> LessonCardViewModel {
        
        return LessonCardViewModel(
            lessonListItem: lessonListItem,
            attachmentsRepository: attachmentsRepository
        )
    }
    
    func refreshData() {
        didPullToRefresh = ()
    }
    
    func pageViewed() {
        
        trackPageViewed()
    }
    
    func lessonCardTapped(lessonListItem: LessonListItemDomainModel) {
        
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(lessonListItem: lessonListItem))
        
        trackLessonTappedAnalytics(lessonListItem: lessonListItem)
    }
}
