//
//  ToolSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class ToolSettingsFlow: Flow {
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(appDiContainer: AppDiContainer) {
        
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController()
    }
    
    func getInitialView() -> UIViewController {
        
        let toolSettingsView = ToolSettingsView()
        let hostingView = ToolSettingsHostingView(view: toolSettingsView)
        
        let transparentModal = TransparentModalView(
            flowDelegate: self,
            modalView: hostingView,
            closeModalFlowStep: .closeToolSettingsModal
        )
        
        return transparentModal
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .closeToolSettingsModal:
            print("Close Modal...")
            
        default:
            break
        }
    }
}
