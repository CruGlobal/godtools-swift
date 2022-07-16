//
//  ArticleAemWebArchiveFileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemWebArchiveFileCacheLocation: FileCacheLocation {
        
    init(filename: String) {
                
        super.init(directory: "webarchives", filename: filename, filePathExtension: "webarchive")
    }
}
