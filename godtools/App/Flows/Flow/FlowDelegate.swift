//
//  FlowDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@MainActor
protocol FlowDelegate: AnyObject {
    
    func navigate(step: FlowStep)
}
