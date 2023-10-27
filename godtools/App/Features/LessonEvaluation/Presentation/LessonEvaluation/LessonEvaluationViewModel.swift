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
    
    private static var evaluateLessonInBackgroundCancellable: AnyCancellable?
    private static var cancelLessonEvaluationInBackgroundCancellable: AnyCancellable?
    
    private let lesson: ToolDomainModel
    private let pageIndexReached: Int
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLessonEvaluationInterfaceStringsUseCase: GetLessonEvaluationInterfaceStringsUseCase
    private let evaluateLessonUseCase: EvaluateLessonUseCase
    private let cancelLessonEvaluationUseCase: CancelLessonEvaluationUseCase
    
    private var currentAppLanguageSubject: CurrentValueSubject<AppLanguageCodeDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var readyToShareFaithScale: Int = 6
    
    let readyToShareFaithMinimumScaleValue: Int = 1
    let readyToShareFaithMaximumScaleValue: Int = 10
    
    let interfaceStrings: ObservableValue<LessonEvaluationInterfaceStringsDomainModel?> = ObservableValue(value: nil)
    let yesIsSelected: ObservableValue<Bool> = ObservableValue(value: false)
    let noIsSelected: ObservableValue<Bool> = ObservableValue(value: false)
    
    private weak var flowDelegate: FlowDelegate?
    
    init(flowDelegate: FlowDelegate, lesson: ToolDomainModel, pageIndexReached: Int, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLessonEvaluationInterfaceStringsUseCase: GetLessonEvaluationInterfaceStringsUseCase, evaluateLessonUseCase: EvaluateLessonUseCase, cancelLessonEvaluationUseCase: CancelLessonEvaluationUseCase) {
        
        self.flowDelegate = flowDelegate
        self.lesson = lesson
        self.pageIndexReached = pageIndexReached
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLessonEvaluationInterfaceStringsUseCase = getLessonEvaluationInterfaceStringsUseCase
        self.evaluateLessonUseCase = evaluateLessonUseCase
        self.cancelLessonEvaluationUseCase = cancelLessonEvaluationUseCase
        
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
        
        LessonEvaluationViewModel.cancelLessonEvaluationInBackgroundCancellable = cancelLessonEvaluationUseCase
            .cancelPublisher(lesson: lesson)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                
            })
        
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
             
        let feedbackHelpful: TrackLessonFeedbackDomainModel.FeedbackHelpful?
        
        if yesIsSelected.value {
            feedbackHelpful = .yes
        }
        else if noIsSelected.value {
            feedbackHelpful = .no
        }
        else {
            feedbackHelpful = nil
        }
        
        let feedback = TrackLessonFeedbackDomainModel(
            feedbackHelpful: feedbackHelpful,
            readinessScaleValue: readyToShareFaithScale,
            pageIndexReached: pageIndexReached
        )
        
        LessonEvaluationViewModel.evaluateLessonInBackgroundCancellable = evaluateLessonUseCase
            .evaluateLessonPublisher(lesson: lesson, feedback: feedback)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                
            })
        
        flowDelegate?.navigate(step: .sendFeedbackTappedFromLessonEvaluation)
    }
}
