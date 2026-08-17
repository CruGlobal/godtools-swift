//
//  LessonEvaluationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class LessonEvaluationViewModel: ObservableObject {
            
    private let stepEmitter: FlowStepEmitter
    private let lessonId: String
    private let lessonLanguage: AppLanguageDomainModel
    private let pageIndexReached: Int
    private let getLessonEvaluationStringsUseCase: GetLessonEvaluationStringsUseCase
    private let didChangeScaleForSpiritualConversationReadinessUseCase: DidChangeScaleForSpiritualConversationReadinessUseCase
    private let evaluateLessonUseCase: EvaluateLessonUseCase
    private let cancelLessonEvaluationUseCase: CancelLessonEvaluationUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
                        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = LessonEvaluationStringsDomainModel.emptyValue
    @Published private(set) var readyToShareFaithScale: SpiritualConversationReadinessScaleDomainModel?
    
    @Published var yesIsSelected: Bool = false
    @Published var noIsSelected: Bool = false
    @Published var readyToShareFaithScaleIntValue: Int = 6
    
    init(
        stepEmitter: FlowStepEmitter,
        lessonId: String,
        lessonLanguage: AppLanguageDomainModel,
        pageIndexReached: Int,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getLessonEvaluationStringsUseCase: GetLessonEvaluationStringsUseCase,
        didChangeScaleForSpiritualConversationReadinessUseCase: DidChangeScaleForSpiritualConversationReadinessUseCase,
        evaluateLessonUseCase: EvaluateLessonUseCase,
        cancelLessonEvaluationUseCase: CancelLessonEvaluationUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.lessonId = lessonId
        self.lessonLanguage = lessonLanguage
        self.pageIndexReached = pageIndexReached
        self.getLessonEvaluationStringsUseCase = getLessonEvaluationStringsUseCase
        self.didChangeScaleForSpiritualConversationReadinessUseCase = didChangeScaleForSpiritualConversationReadinessUseCase
        self.evaluateLessonUseCase = evaluateLessonUseCase
        self.cancelLessonEvaluationUseCase = cancelLessonEvaluationUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetApplanguage(appLanguage: appLanguage)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $appLanguage.dropFirst(),
            $readyToShareFaithScaleIntValue
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (appLanguage: AppLanguageDomainModel, scale: Int) in
            
            self?.didSetAppLanguage(appLanguage: appLanguage, readyToShareFaithScaleValue: scale)
        }
        .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func didSetApplanguage(appLanguage: AppLanguageDomainModel) {

        strings = getLessonEvaluationStringsUseCase
            .execute(appLanguage: appLanguage)
    }
    
    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel, readyToShareFaithScaleValue: Int) {

        Task {

            readyToShareFaithScale = await didChangeScaleForSpiritualConversationReadinessUseCase
                .execute(scale: readyToShareFaithScaleValue, appLanguage: appLanguage)
        }
    }
}

// MARK: - Inputs

extension LessonEvaluationViewModel {
    
    func closeTapped() {
        
        Task {
            try await cancelLessonEvaluationUseCase
                .execute(lessonId: lessonId)
        }
        
        stepEmitter.emit(step: AppFlowStep.closeTappedFromLessonEvaluation)
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
             
        let feedbackHelpful: TrackLessonFeedbackDomainModel.FeedbackHelpful?
        
        if yesIsSelected {
            feedbackHelpful = .yes
        }
        else if noIsSelected {
            feedbackHelpful = .no
        }
        else {
            feedbackHelpful = nil
        }
        
        let feedback = TrackLessonFeedbackDomainModel(
            feedbackHelpful: feedbackHelpful,
            readinessScaleValue: readyToShareFaithScaleIntValue,
            pageIndexReached: pageIndexReached
        )
        
        Task {
            try await evaluateLessonUseCase
                .execute(lessonId: lessonId, feedback: feedback, lessonLanguage: lessonLanguage)
        }
        
        stepEmitter.emit(step: AppFlowStep.sendFeedbackTappedFromLessonEvaluation)
    }
}
