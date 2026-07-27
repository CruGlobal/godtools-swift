//
//  ResourcesFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ResourcesFileCache {
    
    private static let rootDirectory: String = "godtools_resources_files"
    
    let cache: FileCache
    
    init() {
        
        cache = FileCache(rootDirectoryName: Self.rootDirectory)
    }
    
    init(rootDirectory: URL, fileManager: FileManager = FileManager.default) {
        
        cache = FileCache(rootDirectory: rootDirectory, fileManager: fileManager)
    }
}
