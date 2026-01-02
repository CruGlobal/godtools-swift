//
//  LessonEvaluationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class LessonEvaluationViewModel: ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
        
    private let lessonId: String
    private let pageIndexReached: Int
    private let evaluateLessonUseCase: EvaluateLessonUseCase
    private let cancelLessonEvaluationUseCase: CancelLessonEvaluationUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
            
    private weak var flowDelegate: FlowDelegate?
            
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = LessonEvaluationStringsDomainModel.emptyValue
    @Published private(set) var readyToShareFaithScale: SpiritualConversationReadinessScaleDomainModel?
    
    @Published var yesIsSelected: Bool = false
    @Published var noIsSelected: Bool = false
    @Published var readyToShareFaithScaleIntValue: Int = 6
    
    init(
        flowDelegate: FlowDelegate,
        lessonId: String, pageIndexReached: Int,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getLessonEvaluationStringsUseCase: GetLessonEvaluationStringsUseCase,
        didChangeScaleForSpiritualConversationReadinessUseCase: DidChangeScaleForSpiritualConversationReadinessUseCase,
        evaluateLessonUseCase: EvaluateLessonUseCase,
        cancelLessonEvaluationUseCase: CancelLessonEvaluationUseCase
    ) {
        
        self.flowDelegate = flowDelegate
        self.lessonId = lessonId
        self.pageIndexReached = pageIndexReached
        self.evaluateLessonUseCase = evaluateLessonUseCase
        self.cancelLessonEvaluationUseCase = cancelLessonEvaluationUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getLessonEvaluationStringsUseCase
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
            
            didChangeScaleForSpiritualConversationReadinessUseCase
                .execute(scale: scale, translateInAppLanguage: appLanguage)
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (domainModel: SpiritualConversationReadinessScaleDomainModel) in
            self?.readyToShareFaithScale = domainModel
        }
        .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension LessonEvaluationViewModel {
    
    func closeTapped() {
        
        cancelLessonEvaluationUseCase
            .execute(lessonId: lessonId)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                
            })
            .store(in: &Self.backgroundCancellables)
        
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
        
        evaluateLessonUseCase
            .execute(lessonId: lessonId, feedback: feedback)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                
            })
            .store(in: &Self.backgroundCancellables)
        
        flowDelegate?.navigate(step: .sendFeedbackTappedFromLessonEvaluation)
    }
}
