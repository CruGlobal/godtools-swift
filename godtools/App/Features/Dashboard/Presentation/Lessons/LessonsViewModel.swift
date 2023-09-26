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
    private let getLessonsUseCase: GetLessonsUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let attachmentsRepository: AttachmentsRepository
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var sectionTitle: String = ""
    @Published var subtitle: String = ""
    @Published var lessons: [LessonDomainModel] = []
    @Published var isLoadingLessons: Bool = true
        
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, getLessonsUseCase: GetLessonsUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.getLessonsUseCase = getLessonsUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        self.attachmentsRepository = attachmentsRepository
        
        sectionTitle = getInterfaceStringInAppLanguageUseCase.getString(id: "lessons.pageTitle")
        subtitle = getInterfaceStringInAppLanguageUseCase.getString(id: "lessons.pageSubtitle")
                
        getLessonsUseCase.getLessonsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lessons in
                
                self?.lessons = lessons
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
    
    private func trackLessonTappedAnalytics(for lesson: LessonDomainModel) {
        
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
                AnalyticsConstants.Keys.tool: lesson.analyticsToolName
            ]
        )
    }
}

// MARK: - Inputs

extension LessonsViewModel {
    
    func getLessonViewModel(lesson: LessonDomainModel) -> LessonCardViewModel {
        
        return LessonCardViewModel(
            lesson: lesson,
            attachmentsRepository: attachmentsRepository
        )
    }
    
    func refreshData() {
        
        dataDownloader.downloadInitialData()
    }
    
    func pageViewed() {
        
        trackPageViewed()
    }
    
    func lessonCardTapped(lesson: LessonDomainModel) {
        
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(lesson: lesson))
        
        trackLessonTappedAnalytics(for: lesson)
    }
}
