//
//  ArticleAemWebArchive.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemWebArchive: Sendable {
    
    private static let directoryName: String = "webarchives"
    private static let filePathExtension: String = "webarchive"
    
    let location: FileCacheLocation
    
    init(filename: String) {
        
        let relativeUrlString: String = Self.directoryName + "/" + filename + "." + Self.filePathExtension
        
        location = FileCacheLocation(relativeUrlString: relativeUrlString)
    }
}
