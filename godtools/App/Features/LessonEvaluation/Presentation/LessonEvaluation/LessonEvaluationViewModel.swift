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
    private let getLessonEvaluationInterfaceStringsUseCase: GetLessonEvaluationInterfaceStringsUseCase
    private let evaluateLessonUseCase: EvaluateLessonUseCase
    private let cancelLessonEvaluationUseCase: CancelLessonEvaluationUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    private weak var flowDelegate: FlowDelegate?
    
    let readyToShareFaithMinimumScaleValue: Int = 1
    let readyToShareFaithMaximumScaleValue: Int = 10
            
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published var readyToShareFaithScale: Int = 6
    @Published var title: String = ""
    @Published var wasThisHelpful: String = ""
    @Published var yesIsSelected: Bool = false
    @Published var noIsSelected: Bool = false
    @Published var yesButtonTitle: String = ""
    @Published var noButtonTitle: String = ""
    @Published var shareFaithReadiness: String = ""
    @Published var sendFeedbackButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, lessonId: String, pageIndexReached: Int, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLessonEvaluationInterfaceStringsUseCase: GetLessonEvaluationInterfaceStringsUseCase, evaluateLessonUseCase: EvaluateLessonUseCase, cancelLessonEvaluationUseCase: CancelLessonEvaluationUseCase) {
        
        self.flowDelegate = flowDelegate
        self.lessonId = lessonId
        self.pageIndexReached = pageIndexReached
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLessonEvaluationInterfaceStringsUseCase = getLessonEvaluationInterfaceStringsUseCase
        self.evaluateLessonUseCase = evaluateLessonUseCase
        self.cancelLessonEvaluationUseCase = cancelLessonEvaluationUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonEvaluationInterfaceStringsDomainModel, Never> in
                
                return getLessonEvaluationInterfaceStringsUseCase
                    .getStringsPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (interfaceStrings: LessonEvaluationInterfaceStringsDomainModel) in
                
                self?.title = interfaceStrings.title
                self?.wasThisHelpful = interfaceStrings.wasThisHelpful
                self?.yesButtonTitle = interfaceStrings.yesButtonTitle
                self?.noButtonTitle = interfaceStrings.noButtonTitle
                self?.shareFaithReadiness = interfaceStrings.shareFaith
                self?.sendFeedbackButtonTitle = interfaceStrings.sendButtonTitle
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
        
        LessonEvaluationViewModel.cancelLessonEvaluationInBackgroundCancellable = cancelLessonEvaluationUseCase
            .cancelPublisher(lessonId: lessonId)
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
            readinessScaleValue: readyToShareFaithScale,
            pageIndexReached: pageIndexReached
        )
        
        LessonEvaluationViewModel.evaluateLessonInBackgroundCancellable = evaluateLessonUseCase
            .evaluateLessonPublisher(lessonId: lessonId, feedback: feedback)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                
            })
        
        flowDelegate?.navigate(step: .sendFeedbackTappedFromLessonEvaluation)
    }
}
