//
//  ToolSettingsOptionViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Combine
import SwiftUI

class ToolSettingsOptionsViewModel: BaseToolSettingsOptionsViewModel {
    
    private let localizationServices: LocalizationServices
    private let trainingTipsEnabledSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    
    private var trainingTipsCancellable: AnyCancellable?
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        
        super.init()
        
        shareLinkTitle = localizationServices.stringForMainBundle(key: "toolSettings.option.shareLink.title")
        screenShareTitle = localizationServices.stringForMainBundle(key: "toolSettings.option.screenShare.title")
        
        trainingTipsEnabledSubject.send(trainingTipsEnabled)
        
        trainingTipsCancellable = trainingTipsEnabledSubject.sink { [weak self] (trainingTipsEnabled: Bool) in
            self?.trainingTipsTitle = trainingTipsEnabled ? localizationServices.stringForMainBundle(key: "toolSettings.option.trainingTips.hide.title") : localizationServices.stringForMainBundle(key: "toolSettings.option.trainingTips.show.title")
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
