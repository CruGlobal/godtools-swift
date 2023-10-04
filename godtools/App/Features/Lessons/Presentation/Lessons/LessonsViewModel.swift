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
        
    private let dataDownloader: InitialDataDownloader
    private let getLessonsListUseCase: GetLessonsListUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let attachmentsRepository: AttachmentsRepository
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var sectionTitle: String = ""
    @Published var subtitle: String = ""
    @Published var lessons: [LessonListItemDomainModel] = []
    @Published var isLoadingLessons: Bool = true
        
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, getLessonsListUseCase: GetLessonsListUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.getLessonsListUseCase = getLessonsListUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.attachmentsRepository = attachmentsRepository
        
        getInterfaceStringInAppLanguageUseCase.observeStringChangedPublisher(id: "lessons.pageTitle")
            .receive(on: DispatchQueue.main)
            .assign(to: &$sectionTitle)
        
        getInterfaceStringInAppLanguageUseCase.observeStringChangedPublisher(id: "lessons.pageSubtitle")
            .receive(on: DispatchQueue.main)
            .assign(to: &$subtitle)
                
        getLessonsListUseCase.observeLessonsListPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (lessonsList: [LessonListItemDomainModel]) in
                
                self?.lessons = lessonsList
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
                AnalyticsConstants.Keys.tool: lessonListItem.lesson.analyticsToolName
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
        
        dataDownloader.downloadInitialData()
    }
    
    func pageViewed() {
        
        trackPageViewed()
    }
    
    func lessonCardTapped(lessonListItem: LessonListItemDomainModel) {
        
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(lessonListItem: lessonListItem))
        
        trackLessonTappedAnalytics(lessonListItem: lessonListItem)
    }
}
