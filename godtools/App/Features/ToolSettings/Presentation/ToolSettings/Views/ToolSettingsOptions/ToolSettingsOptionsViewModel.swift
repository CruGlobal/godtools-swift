//
//  ToolSettingsOptionViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation

class ToolSettingsOptionsViewModel: BaseToolSettingsOptionsViewModel {
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
        
        super.init()
    }
    
    override func shareLinkTapped() {
        flowDelegate?.navigate(step: .shareLinkTappedFromToolSettings)
    }
    
    override func screenShareTapped() {
        flowDelegate?.navigate(step: .screenShareTappedFromToolSettings)
    }
    
    override func trainingTipsTapped() {
        print("training tips tapped...")
        
        flowDelegate?.navigate(step: .enableTrainingTipsTappedFromToolSettings)
    }
}
