//
//  ToolSettingsTopBarViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolSettingsTopBarViewModel: BaseToolSettingsTopBarViewModel {
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate) {
        
        self.flowDelegate = flowDelegate
    }
    
    override func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolSettings)
    }
}
