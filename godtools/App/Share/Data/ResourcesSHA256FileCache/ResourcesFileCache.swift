//
//  ResourcesFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ResourcesFileCache: FileCache {
    
    private static let rootDirectory: String = "godtools_resources_files"
    
    init() {
        super.init(rootDirectoryName: Self.rootDirectory)
    }
    
    override init(rootDirectory: URL, fileManager: FileManager = FileManager.default) {
        super.init(rootDirectory: rootDirectory, fileManager: fileManager)
    }
}
