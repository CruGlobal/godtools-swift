//
//  ToolSettingsChooseLanguageViewModel.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import Foundation

class ToolSettingsChooseLanguageViewModel: BaseToolSettingsChooseLanguageViewModel {
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
        
        super.init()
        
        primaryLanguageTitle = "Primary"
        parallelLanguageTitle = "Parallel"
    }
    
    override func primaryLanguageTapped() {
        
        flowDelegate?.navigate(step: .primaryLanguageTappedFromToolSettings)
    }
    
    override func parallelLanguageTapped() {
        
        flowDelegate?.navigate(step: .parallelLanguageTappedFromToolSettings)
    }
    
    override func swapLanguageTapped() {
        
        flowDelegate?.navigate(step: .swapLanguagesTappedFromToolSettings)
    }
}
