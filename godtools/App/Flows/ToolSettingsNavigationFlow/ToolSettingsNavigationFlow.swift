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
    
    func openToolSettings(toolSettingsObserver: ToolSettingsObserver, toolSettingsDidCloseClosure: (() -> Void)?) {
        
        let toolSettingsFlow = ToolSettingsFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            presentInNavigationController: navigationController,
            toolSettingsObserver: toolSettingsObserver,
            toolSettingsDidCloseClosure: toolSettingsDidCloseClosure
        )
        
        self.toolSettingsFlow = toolSettingsFlow
    }
    
    func closeToolSettings() {
        
        guard toolSettingsFlow != nil else {
            return
        }
        
        navigationController.dismissPresented(animated: true) { [weak self] in
            
            self?.toolSettingsFlow?.didClose()
            self?.toolSettingsFlow = nil
        }
    }
}
