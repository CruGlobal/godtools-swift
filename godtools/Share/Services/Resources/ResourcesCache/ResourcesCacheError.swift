//
//  ResourcesCacheError.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourcesCacheError: Error {
    case failedToCacheResources(error: Error)
}
