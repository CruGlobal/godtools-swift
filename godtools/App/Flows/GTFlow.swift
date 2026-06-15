//
//  GTFlow.swift
//  godtools
//
//  Created by Levi Eggert on 6/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit

open class GTFlow: Flow {
    
    static var defaultAppNavigationController: AppNavigationController {
        return AppNavigationController(navigationBarAppearance: nil)
    }
    
    let appDiContainer: AppDiContainer
    
    var appNavigationController: AppNavigationController? {
        return navigationController as? AppNavigationController
    }
    
    init(
        appDiContainer: AppDiContainer,
        initialView: UIViewController?,
        stepEmitter: FlowStepEmitter,
        navigationController: AppNavigationController = GTFlow.defaultAppNavigationController,
        onPresentType: Flow.OnPresentType = Flow.defaultOnPresentType
    ) {
        print("init flow: \(type(of: self))")
        
        self.appDiContainer = appDiContainer
        
        super.init(
            initialView: initialView,
            stepEmitter: stepEmitter,
            navigationController: navigationController,
            onPresentType: onPresentType
        )
    }
    
    init(
        appDiContainer: AppDiContainer,
        navigationController: AppNavigationController = GTFlow.defaultAppNavigationController,
        onPresentType: Flow.OnPresentType = Flow.defaultOnPresentType
    ) {
        print("init flow: \(type(of: self))")
        
        self.appDiContainer = appDiContainer
        
        super.init(
            initialView: nil,
            stepEmitter: FlowStepEmitter(),
            navigationController: navigationController,
            onPresentType: onPresentType
        )
    }
    
    deinit {
        print("x deinit flow: \(type(of: self))")
    }
    
    open override func navigate(step: FlowStep) {
        
    }
}
