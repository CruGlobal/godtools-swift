//
//  ArticleAemDownloaderError.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ArticleAemDownloaderError: Error, Sendable {
    
    case cancelled
    case noNetworkConnection
    case unknownError
}
