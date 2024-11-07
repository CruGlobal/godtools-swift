//
//  AlertMessageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AlertMessageViewModel: AlertMessageViewModelType {
    
    private let acceptTappedFlowStep: FlowStep?
    
    private weak var flowDelegate: FlowDelegate?
    
    let title: String?
    let message: String?
    let cancelTitle: String?
    let acceptTitle: String
    
    init(title: String?, message: String?, cancelTitle: String?, acceptTitle: String, flowDelegate: FlowDelegate? = nil, acceptTappedFlowStep: FlowStep? = nil) {
        
        self.flowDelegate = flowDelegate
        self.acceptTappedFlowStep = acceptTappedFlowStep
        
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.acceptTitle = acceptTitle
    }
    
    func acceptTapped() {
        
        if let step = acceptTappedFlowStep {
            flowDelegate?.navigate(step: step)
        }
    }
}
