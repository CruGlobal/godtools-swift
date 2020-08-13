//
//  TutorialItemViewBuilder.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialItemViewBuilder: CustomViewBuilderType {
    
    private let deviceLanguage: DeviceLanguageType
    
    required init(deviceLanguage: DeviceLanguageType) {
        
        self.deviceLanguage = deviceLanguage
    }
    
    func buildCustomView(customViewId: String) -> UIView? {
        
        if let tutorialViewId = CustomTutorialViewId(rawValue: customViewId) {
            
            switch tutorialViewId {
            
            case .tutorialTools:
                let tutorialTools: TutorialToolsView = TutorialToolsView()
                tutorialTools.configure(viewModel: TutorialToolsViewModel(deviceLanguage: deviceLanguage))
                return tutorialTools
                
            case .tutorialInMenu:
                let tutorialInMenu: TutorialInMenuView = TutorialInMenuView()
                tutorialInMenu.configure(viewModel: TutorialInMenuViewModel(deviceLanguage: deviceLanguage))
                return tutorialInMenu
            }
        }
        
        return nil
    }
}
