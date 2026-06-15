//
//  FlowTesting.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit
@testable import godtools

@MainActor
protocol FlowTesting {
    
}

extension FlowTesting {
    
    func getWindowAndAttachRootForPresentation(root: UIViewController) -> UIWindow {
        
        let window = UIWindow()
        window.rootViewController = root
        window.makeKeyAndVisible()
        return window
    }
    
    func getNewRootFlow(
        initialView: UIViewController = UIViewController(),
        stepEmitter: FlowStepEmitter = FlowStepEmitter(),
        navigationController: UINavigationController = UINavigationController()
    ) -> RootFlow {
    
        return RootFlow(initialView: UIViewController(), stepEmitter: FlowStepEmitter(), navigationController: navigationController)
    }
    
    func getNewFlow(onPresentType: Flow.OnPresentType = .presentNavigationController) -> Flow {
        return Flow(
            initialView: UIViewController(),
            stepEmitter: FlowStepEmitter(),
            onPresentType: onPresentType
        )
    }
    
    func getNewTestFlow() -> TestFlow {
        return TestFlow()
    }
}
