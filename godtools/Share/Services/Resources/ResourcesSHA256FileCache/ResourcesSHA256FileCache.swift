//
//  ResourcesSHA256FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesSHA256FileCache: SHA256FilesCache {
    
    required init(rootDirectory: String = "godtools_resources_files") {
        
        super.init(rootDirectory: rootDirectory)
    }
}
