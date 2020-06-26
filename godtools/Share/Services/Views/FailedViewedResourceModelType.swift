//
//  FailedViewedResourceModelType.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FailedViewedResourceModelType {
    
    var resourceId: String { get }
    var failedViewsCount: Int { get }
}
