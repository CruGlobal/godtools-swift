//
//  InitialDataDownloaderError.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum InitialDataDownloaderError: Error {
    
    case failedToDownloadResources(error: ResourcesDownloaderError)
    case failedToCacheResources(error: Error)
    case failedToGetResourcesDownloaderResult
}
