//
//  AnalyticsEventModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol AnalyticsEventModelType {
        
    var attribute: AnalyticsAttributeModel? { get }
    var action: String? { get }
    var delay: String? { get }
    var systems: [String] { get }
    var trigger: String? { get }
}
