//
//  AppFlowType.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol AppFlowType: FlowDelegate {
    var appDiContainer: AppDiContainer { get }
    var rootController: AppRootController { get }
    var navigationController: UINavigationController { get }
    
    func resetFlowToToolsFlow(animated: Bool)
    func navigate(step: FlowStep)
}
