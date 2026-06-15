//
//  RootFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit

@MainActor
open class RootFlow: Flow {
    
    public enum RepresentableView {
        case custom(view: UIViewController)
        case useNavigationController
    }
    
    public let view: ViewControllerRepresentable
    
    public init(
        initialView: UIViewController?,
        stepEmitter: FlowStepEmitter,
        rootView: RepresentableView = .useNavigationController,
        navigationController: UINavigationController = UINavigationController()
    ) {
        
        let representableView: UIViewController
        
        switch rootView {
        case .custom(let view):
            representableView = view
        case .useNavigationController:
            representableView = navigationController
        }
        
        view = ViewControllerRepresentable(
            viewController: representableView
        )
        
        if let initialView = initialView {
            navigationController.setViewControllers([initialView], animated: false)
        }
        
        super.init(initialView: initialView, stepEmitter: stepEmitter, navigationController: navigationController)
    }
    
    public override func setNavigationController(navigationController: UINavigationController) {
        // Overriding the set navigation controller and will not allow on the root.
    }
}
