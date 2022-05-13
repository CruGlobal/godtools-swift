//
//  ToolSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class ToolSettingsFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController()
    }
    
    func getInitialView() -> UIViewController {
        
        let viewModel = ToolSettingsViewModel(flowDelegate: self)
        
        let toolSettingsView = ToolSettingsView(viewModel: viewModel)
        
        let hostingView = ToolSettingsHostingView(view: toolSettingsView)
        
        let transparentModal = TransparentModalView(
            flowDelegate: self,
            modalView: hostingView,
            closeModalFlowStep: .closeTappedFromToolSettings
        )
        
        return transparentModal
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .closeTappedFromToolSettings:
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted(state: .userClosedToolSettings))
            
        case .shareLinkTappedFromToolSettings:
            break
            
        case .screenShareTappedFromToolSettings:
            break
            
        case .enableTrainingTipsTappedFromToolSettings:
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted(state: .userEnabledTrainingTips))
            
        case .disableTrainingTipsTappedFromToolSettings:
            flowDelegate?.navigate(step: .toolSettingsFlowCompleted(state: .userDisabledTrainingTips))
            
        default:
            break
        }
    }
}
