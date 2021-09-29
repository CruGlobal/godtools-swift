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
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, localization: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.localization = localization
        
        title = localization.stringForMainBundle(key: "")
        wasThisHelpful = localization.stringForMainBundle(key: "")
        yesButtonTitle = localization.stringForMainBundle(key: "")
        noButtonTitle = localization.stringForMainBundle(key: "")
        shareFaith = localization.stringForMainBundle(key: "")
        sendButtonTitle = localization.stringForMainBundle(key: "")
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromLessonEvaluation)
    }
}
