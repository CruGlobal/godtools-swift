//
//  ToolSettingsOptionViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Combine
import SwiftUI

class ToolSettingsOptionsViewModel: BaseToolSettingsOptionsViewModel {
    
    private let trainingTipsEnabledSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    private var trainingTipsCancellable: AnyCancellable?
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        
        super.init()
        
        trainingTipsEnabledSubject.send(trainingTipsEnabled)
        
        trainingTipsCancellable = trainingTipsEnabledSubject.sink { [weak self] (trainingTipsEnabled: Bool) in
            self?.trainingTipsTitle = trainingTipsEnabled ? "Hide tips" : "Training tips"
            self?.trainingTipsIcon = trainingTipsEnabled ? Image(ImageCatalog.toolSettingsOptionHideTips.name) : Image(ImageCatalog.toolSettingsOptionTrainingTips.name)
        }
    }
    
    override func shareLinkTapped() {
        flowDelegate?.navigate(step: .shareLinkTappedFromToolSettings)
    }
    
    override func screenShareTapped() {
        flowDelegate?.navigate(step: .screenShareTappedFromToolSettings)
    }
    
    override func trainingTipsTapped() {

        trainingTipsEnabledSubject.send(!trainingTipsEnabledSubject.value)
                
        let step: FlowStep = trainingTipsEnabledSubject.value ? .enableTrainingTipsTappedFromToolSettings : .disableTrainingTipsTappedFromToolSettings
        
        flowDelegate?.navigate(step: step)
    }
}
