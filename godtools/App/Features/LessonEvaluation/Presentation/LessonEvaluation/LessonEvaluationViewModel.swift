//
//  LessonEvaluationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonEvaluationViewModel {
    
    private let lesson: ResourceModel
    private let pageIndexReached: Int
    private let lessonEvaluationRepository: LessonEvaluationRepository
    private let lessonFeedbackAnalytics: LessonFeedbackAnalytics
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let localization: LocalizationServices
    
    private(set) var readyToShareFaithScale: Int = 6
    
    let title: String
    let wasThisHelpful: String
    let yesButtonTitle: String
    let noButtonTitle: String
    let shareFaith: String
    let readyToShareFaithMinimumScaleValue: Int = 1
    let readyToShareFaithMaximumScaleValue: Int = 10
    let sendButtonTitle: String
    let yesIsSelected: ObservableValue<Bool> = ObservableValue(value: false)
    let noIsSelected: ObservableValue<Bool> = ObservableValue(value: false)
    
    private weak var flowDelegate: FlowDelegate?
    
    init(flowDelegate: FlowDelegate, lesson: ResourceModel, pageIndexReached: Int, lessonEvaluationRepository: LessonEvaluationRepository, lessonFeedbackAnalytics: LessonFeedbackAnalytics, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, localization: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.lesson = lesson
        self.pageIndexReached = pageIndexReached
        self.lessonEvaluationRepository = lessonEvaluationRepository
        self.lessonFeedbackAnalytics = lessonFeedbackAnalytics
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.localization = localization
        
        let primaryLocaleIdentifier: String? = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier
        
        title = localization.stringForLocaleElseSystem(localeIdentifier: primaryLocaleIdentifier, key: "lesson_evaluation.title")
        wasThisHelpful = localization.stringForLocaleElseSystem(localeIdentifier: primaryLocaleIdentifier, key: "lesson_evaluation.wasThisHelpful")
        yesButtonTitle = localization.stringForLocaleElseSystem(localeIdentifier: primaryLocaleIdentifier, key: "yes")
        noButtonTitle = localization.stringForLocaleElseSystem(localeIdentifier: primaryLocaleIdentifier, key: "no")
        shareFaith = localization.stringForLocaleElseSystem(localeIdentifier: primaryLocaleIdentifier, key: "lesson_evaluation.shareFaith")
        sendButtonTitle = localization.stringForLocaleElseSystem(localeIdentifier: primaryLocaleIdentifier, key: "lesson_evaluation.sendButtonTitle")
    }
}

// MARK: - Inputs

extension LessonEvaluationViewModel {
    
    func closeTapped() {
        
        lessonEvaluationRepository.storeLessonEvaluation(
            lesson: lesson,
            lessonEvaluated: false
        )
        
        flowDelegate?.navigate(step: .closeTappedFromLessonEvaluation)
    }
    
    func yesTapped() {
        
        yesIsSelected.accept(value: true)
        noIsSelected.accept(value: false)
    }
    
    func noTapped() {
        
        yesIsSelected.accept(value: false)
        noIsSelected.accept(value: true)
    }
    
    func didSetScaleForReadyToShareFaith(scale: Int) {
        
        readyToShareFaithScale = scale
    }
    
    func sendTapped() {
                
        lessonEvaluationRepository.storeLessonEvaluation(
            lesson: lesson,
            lessonEvaluated: true
        )
        
        let feedbackHelpful: LessonFeedbackHelpful?
        
        if yesIsSelected.value {
            feedbackHelpful = .yes
        }
        else if noIsSelected.value {
            feedbackHelpful = .no
        }
        else {
            feedbackHelpful = nil
        }
        
        lessonFeedbackAnalytics.trackLessonFeedback(
            siteSection: lesson.abbreviation,
            feedbackHelpful: feedbackHelpful,
            readinessScaleValue: readyToShareFaithScale,
            pageIndexReached: pageIndexReached
        )
        
        flowDelegate?.navigate(step: .sendFeedbackTappedFromLessonEvaluation)
    }
}
