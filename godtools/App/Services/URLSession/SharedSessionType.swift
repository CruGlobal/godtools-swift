//
//  SharedSessionType.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // TODO: Will be replaced with Common/URLSession/IgnoreCacheSession. GT-1727 ~Levi
protocol SharedSessionType {
    
    var session: URLSession { get }
}
