//
//  ToolSettingsViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation

class ToolSettingsViewModel: BaseToolSettingsViewModel {
    
    private let trainingTipsEnabled: Bool
    
    private weak var flowDelegate: FlowDelegate?
        
    required init(flowDelegate: FlowDelegate, trainingTipsEnabled: Bool) {
        
        self.flowDelegate = flowDelegate
        self.trainingTipsEnabled = trainingTipsEnabled
    }
    
    override func getTopBarViewModel() -> BaseToolSettingsTopBarViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsTopBarViewModel()
        }

        return ToolSettingsTopBarViewModel(flowDelegate: flowDelegate)
    }
    
    override func getOptionsViewModel() -> BaseToolSettingsOptionsViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsOptionsViewModel()
        }
        
        return ToolSettingsOptionsViewModel(flowDelegate: flowDelegate, trainingTipsEnabled: trainingTipsEnabled)
    }
    
    override func getChooseLanguageViewModel() -> BaseToolSettingsChooseLanguageViewModel {
        
        guard let flowDelegate = flowDelegate else {
            assertionFailure("Failed to instantiate viewModel, flowDelegate should not be nil.")
            return BaseToolSettingsChooseLanguageViewModel()
        }
        
        return ToolSettingsChooseLanguageViewModel(flowDelegate: flowDelegate)
    }
}
