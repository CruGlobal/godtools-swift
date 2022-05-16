//
//  ToolSettingsOptionViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import SwiftUI

class ToolSettingsOptionsViewModel: BaseToolSettingsOptionsViewModel {
    
    private let trainingTipsEnabled: Bool
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        self.trainingTipsEnabled = trainingTipsEnabled
        
        super.init()
        
        trainingTipsTitle = trainingTipsEnabled ? "Hide tips" : "Training tips"
        trainingTipsIcon = trainingTipsEnabled ? Image(ImageCatalog.toolSettingsOptionHideTips.name) : Image(ImageCatalog.toolSettingsOptionTrainingTips.name)
    }
    
    override func shareLinkTapped() {
        flowDelegate?.navigate(step: .shareLinkTappedFromToolSettings)
    }
    
    override func screenShareTapped() {
        flowDelegate?.navigate(step: .screenShareTappedFromToolSettings)
    }
    
    override func trainingTipsTapped() {

        let step: FlowStep = trainingTipsEnabled ? .disableTrainingTipsTappedFromToolSettings : .enableTrainingTipsTappedFromToolSettings
        
        flowDelegate?.navigate(step: step)
    }
}
