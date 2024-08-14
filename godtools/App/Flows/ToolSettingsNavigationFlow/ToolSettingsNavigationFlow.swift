//
//  ToolSettingsNavigationFlow.swift
//  godtools
//
//  Created by Rachael Skeath on 8/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol ToolSettingsNavigationFlow: Flow {
    
    var toolSettingsFlow: ToolSettingsFlow? { get set }
}

extension ToolSettingsNavigationFlow {
    
    func openToolSettings(with toolSettingsObserver: ToolSettingsObserver) {
        let toolSettingsFlow = ToolSettingsFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            toolSettingsObserver: toolSettingsObserver
        )
        
        navigationController.present(toolSettingsFlow.getInitialView(), animated: true)
        
        self.toolSettingsFlow = toolSettingsFlow
    }
    
    func closeToolSettings() {
        
        guard toolSettingsFlow != nil else {
            return
        }
    
        navigationController.dismiss(animated: true)
        
        toolSettingsFlow = nil
    }
}
