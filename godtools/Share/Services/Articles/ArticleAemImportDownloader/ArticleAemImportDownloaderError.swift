//
//  ArticleAemImportDownloaderError.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ArticleAemImportDownloaderError: Error {
    
    case cancelled
    case noNetworkConnection
    case unknownError
}
