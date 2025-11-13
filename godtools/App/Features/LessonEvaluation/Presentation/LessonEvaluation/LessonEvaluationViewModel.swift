//
//  LessonEvaluationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

class LessonEvaluationViewModel: ObservableObject {
    
    private static var evaluateLessonInBackgroundCancellable: AnyCancellable?
    private static var cancelLessonEvaluationInBackgroundCancellable: AnyCancellable?
    
    private let lessonId: String
    private let pageIndexReached: Int
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let evaluateLesson: EvaluateLesson
    private let cancelLessonEvaluation: CancelLessonEvaluation
            
    private weak var flowDelegate: FlowDelegate?
            
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = LessonEvaluationStrings.emptyValue
    @Published private(set) var readyToShareFaithScale = SpiritualConversationReadinessScale.emptyValue
    
    @Published var yesIsSelected: Bool = false
    @Published var noIsSelected: Bool = false
    @Published var readyToShareFaithScaleIntValue: Int = 6
    
    init(
        flowDelegate: FlowDelegate,
        lessonId: String, pageIndexReached: Int,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getLessonEvaluationStrings: GetLessonEvaluationStrings,
        didChangeScaleForSpiritualConversationReadiness: DidChangeScaleForSpiritualConversationReadiness,
        evaluateLesson: EvaluateLesson,
        cancelLessonEvaluation: CancelLessonEvaluation
    ) {
        
        self.flowDelegate = flowDelegate
        self.lessonId = lessonId
        self.pageIndexReached = pageIndexReached
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.evaluateLesson = evaluateLesson
        self.cancelLessonEvaluation = cancelLessonEvaluation
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getLessonEvaluationStrings
                    .execute(translateInAppLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$strings)
        
        Publishers.CombineLatest(
            $appLanguage.dropFirst(),
            $readyToShareFaithScaleIntValue
        )
        .map { (appLanguage: AppLanguageDomainModel, scale: Int) in
            
            didChangeScaleForSpiritualConversationReadiness
                .execute(scale: scale, translateInAppLanguage: appLanguage)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .assign(to: &$readyToShareFaithScale)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension LessonEvaluationViewModel {
    
    func closeTapped() {
        
        LessonEvaluationViewModel.cancelLessonEvaluationInBackgroundCancellable = cancelLessonEvaluation
            .execute(lessonId: lessonId)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                
            })
        
        flowDelegate?.navigate(step: .closeTappedFromLessonEvaluation)
    }
    
    func yesTapped() {
        
        yesIsSelected = true
        noIsSelected = false
    }
    
    func noTapped() {
        
        yesIsSelected = false
        noIsSelected = true
    }
    
    func sendFeedbackTapped() {
             
        let feedbackHelpful: TrackLessonFeedback.FeedbackHelpful?
        
        if yesIsSelected {
            feedbackHelpful = .yes
        }
        else if noIsSelected {
            feedbackHelpful = .no
        }
        else {
            feedbackHelpful = nil
        }
        
        let feedback = TrackLessonFeedback(
            feedbackHelpful: feedbackHelpful,
            readinessScaleValue: readyToShareFaithScaleIntValue,
            pageIndexReached: pageIndexReached
        )
        
        LessonEvaluationViewModel.evaluateLessonInBackgroundCancellable = evaluateLesson
            .execute(lessonId: lessonId, feedback: feedback)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                
            })
        
        flowDelegate?.navigate(step: .sendFeedbackTappedFromLessonEvaluation)
    }
}
