//
//  DeleteResourcesFilesResult.swift
//  godtools
//
//  Created by Levi Eggert on 8/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct DeleteResourcesFilesResult {
    
    let filesRemoved: [FileCacheLocation]
    let removeFileErrors: [Error]
    let writeError: Error?
}
