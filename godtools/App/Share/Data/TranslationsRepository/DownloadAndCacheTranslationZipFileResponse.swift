//
//  DownloadAndCacheTranslationZipFileResponse.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DownloadAndCacheTranslationZipFileResponse {
    
    let fileCacheLocations: [FileCacheLocation]
    let urlResponseObject: URLResponseObject?
    
    init(fileCacheLocations: [FileCacheLocation], urlResponseObject: URLResponseObject?) {
        
        self.fileCacheLocations = fileCacheLocations
        self.urlResponseObject = urlResponseObject
    }
}
