//
//  ArticleAemWebArchiveFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemWebArchiveFileCache: FileCacheType {
   
    private let rootDirectoryName: String = "articles_webarchives"
    
    let fileManager: FileManager = FileManager.default
    let errorDomain: String
    
    required init() {
        errorDomain = String(describing: ArticleAemWebArchiveFileCache.self)
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
