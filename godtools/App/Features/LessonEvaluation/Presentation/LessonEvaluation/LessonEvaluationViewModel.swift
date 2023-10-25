//
//  LessonEvaluationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

class LessonEvaluationViewModel {
    
    private let lesson: ResourceModel
    private let pageIndexReached: Int
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLessonEvaluationInterfaceStringsUseCase: GetLessonEvaluationInterfaceStringsUseCase
    private let lessonEvaluationRepository: LessonEvaluationRepository
    private let lessonFeedbackAnalytics: LessonFeedbackAnalytics
    
    private var currentAppLanguageSubject: CurrentValueSubject<AppLanguageCodeDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var readyToShareFaithScale: Int = 6
    
    let readyToShareFaithMinimumScaleValue: Int = 1
    let readyToShareFaithMaximumScaleValue: Int = 10
    
    let interfaceStrings: ObservableValue<LessonEvaluationInterfaceStringsDomainModel?> = ObservableValue(value: nil)
    let yesIsSelected: ObservableValue<Bool> = ObservableValue(value: false)
    let noIsSelected: ObservableValue<Bool> = ObservableValue(value: false)
    
    private weak var flowDelegate: FlowDelegate?
    
    init(flowDelegate: FlowDelegate, lesson: ResourceModel, pageIndexReached: Int, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLessonEvaluationInterfaceStringsUseCase: GetLessonEvaluationInterfaceStringsUseCase, lessonEvaluationRepository: LessonEvaluationRepository, lessonFeedbackAnalytics: LessonFeedbackAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.lesson = lesson
        self.pageIndexReached = pageIndexReached
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLessonEvaluationInterfaceStringsUseCase = getLessonEvaluationInterfaceStringsUseCase
        self.lessonEvaluationRepository = lessonEvaluationRepository
        self.lessonFeedbackAnalytics = lessonFeedbackAnalytics
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageCodeDomainModel) in
                
                self?.currentAppLanguageSubject.send(appLanguage)
            }
            .store(in: &cancellables)
        
        getLessonEvaluationInterfaceStringsUseCase
            .getStringsPublisher(appLanguageCodeChangedPublisher: currentAppLanguageSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (interfaceStrings: LessonEvaluationInterfaceStringsDomainModel) in
                
                self?.interfaceStrings.accept(value: interfaceStrings)
            }
            .store(in: &cancellables)
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
