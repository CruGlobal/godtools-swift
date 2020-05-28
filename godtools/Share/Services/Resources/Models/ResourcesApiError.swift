//
//  ResourcesApiError.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourcesApiError: Error {
    
    case cancelled
    case noNetworkConnection
    case unknownError(error: Error)
}
