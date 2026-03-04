//
//  LocalizationSettingsNavigationFlow.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

@MainActor protocol LocalizationSettingsNavigationFlow: Flow {
    
    var localizationSettingsFlow: LocalizationSettingsFlow? { get set }
}

extension LocalizationSettingsNavigationFlow {
    
    func navigateToLocalizationSettings(showsPreferNotToSay: Bool, shouldStoreCountryWhenSelected: Bool) {
        
        guard localizationSettingsFlow == nil else {
            return
        }
        
        let localizationSettingsFlow = LocalizationSettingsFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController,
            showsPreferNotToSay: showsPreferNotToSay,
            shouldStoreCountryWhenSelected: shouldStoreCountryWhenSelected
        )
        
        self.localizationSettingsFlow = localizationSettingsFlow
    }
    
    func navigateBackFromLocalizationSettingsFlow() {
        
        guard localizationSettingsFlow != nil else {
            return
        }
        
        navigationController.popViewController(animated: true)
        
        localizationSettingsFlow = nil
    }
}
