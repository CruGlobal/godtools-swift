//
//  LessonEvaluationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonEvaluationViewModel: LessonEvaluationViewModelType {
    
    private let localization: LocalizationServices
    
    let title: String
    let wasThisHelpful: String
    let yesButtonTitle: String
    let noButtonTitle: String
    let shareFaith: String
    let sendButtonTitle: String
    let yesIsSelected: ObservableValue<Bool> = ObservableValue(value: false)
    let noIsSelected: ObservableValue<Bool> = ObservableValue(value: false)
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, localization: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.localization = localization
        
        title = localization.stringForMainBundle(key: "lesson_evaluation.title")
        wasThisHelpful = localization.stringForMainBundle(key: "lesson_evaluation.wasThisHelpful")
        yesButtonTitle = localization.stringForMainBundle(key: "yes")
        noButtonTitle = localization.stringForMainBundle(key: "no")
        shareFaith = localization.stringForMainBundle(key: "lesson_evaluation.shareFaith")
        sendButtonTitle = localization.stringForMainBundle(key: "lesson_evaluation.sendButtonTitle")
    }
    
    func closeTapped() {
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
    
    func sendTapped() {
        
    }
}
