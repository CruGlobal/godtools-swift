//
//  Flow.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@MainActor protocol Flow: FlowDelegate {
    
    var appDiContainer: AppDiContainer { get }
    var navigationController: AppNavigationController { get }
}
