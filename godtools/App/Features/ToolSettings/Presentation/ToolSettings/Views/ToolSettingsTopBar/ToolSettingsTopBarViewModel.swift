//
//  ToolSettingsTopBarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolSettingsTopBarViewModel: BaseToolSettingsTopBarViewModel {
    
    private let localizationServices: LocalizationServices
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        
        super.init()
    
        title = localizationServices.stringForMainBundle(key: "toolSettings.title")
    }
    
    override func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolSettings)
    }
}
