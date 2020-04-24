//
//  ZipFileContentsCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ZipFileContentsCache: ZipFileContentsCacheType {
    
    private let rootDirectoryName: String = "zip_cache_contents"
    
    let fileManager: FileManager = FileManager.default
    let errorDomain: String
    
    required init() {
        self.errorDomain = String(describing: ZipFileContentsCache.self)
    }
    
    func getRootDirectory() -> Result<URL, Error> {
    
        do {
            let documentsDirectory: URL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            return .success(documentsDirectory.appendingPathComponent(rootDirectoryName))
        }
        catch let error {
            return .failure(error)
        }
    }
}
