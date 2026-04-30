//
//  DeleteResourcesFilesResult.swift
//  godtools
//
//  Created by Levi Eggert on 8/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct DeleteResourcesFilesResult: Sendable {
    
    let filesRemoved: [FileCacheLocation]
}
