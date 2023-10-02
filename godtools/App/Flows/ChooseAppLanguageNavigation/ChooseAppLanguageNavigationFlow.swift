//
//  ChooseAppLanguageNavigationFlow.swift
//  godtools
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol ChooseAppLanguageNavigationFlow: Flow {
    
    var chooseAppLanguageFlow: ChooseAppLanguageFlow? { get set }
}

extension ChooseAppLanguageNavigationFlow {
    
    func navigateToChooseAppLanguageFlow() {
        
        guard chooseAppLanguageFlow == nil else {
            return
        }
        
        let chooseAppLanguageFlow = ChooseAppLanguageFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            sharedNavigationController: navigationController
        )
        
        self.chooseAppLanguageFlow = chooseAppLanguageFlow
    }
    
    func navigateBackFromChooseAppLanguageFlow() {
        
        guard chooseAppLanguageFlow != nil else {
            return
        }
        
        navigationController.popViewController(animated: true)
        
        chooseAppLanguageFlow = nil
    }
}
