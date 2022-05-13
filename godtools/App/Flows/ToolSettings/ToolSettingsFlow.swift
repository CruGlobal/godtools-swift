//
//  ToolSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class ToolSettingsFlow: Flow {
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(appDiContainer: AppDiContainer) {
        
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController()
    }
    
    func navigate(step: FlowStep) {
        
    }
}
