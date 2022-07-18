//
//  ArticleAemWebArchiveFileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemWebArchiveFileCacheLocation: FileCacheLocation {
    
    private static let directoryName: String = "webarchives"
    private static let filePathExtension: String = "webarchive"
    
    init(filename: String) {
        
        let relativeUrlString: String = ArticleAemWebArchiveFileCacheLocation.directoryName + "/" + filename + "." + ArticleAemWebArchiveFileCacheLocation.filePathExtension
        
        super.init(relativeUrlString: relativeUrlString)
    }
}
