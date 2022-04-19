//
//  FlowDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FlowDelegate: AnyObject {
    
    func navigate(step: FlowStep)
}

class MockFlowDelegate: FlowDelegate {
    func navigate(step: FlowStep) { }
}
