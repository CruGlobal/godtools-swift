//
//  DownloadAndCacheTranslationFileResponse.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DownloadAndCacheTranslationFileResponse {
    
    let fileCacheLocation: FileCacheLocation?
    let urlResponseObject: URLResponseObject?
    
    init(fileCacheLocation: FileCacheLocation?, urlResponseObject: URLResponseObject?) {
        
        self.fileCacheLocation = fileCacheLocation
        self.urlResponseObject = urlResponseObject
    }
}
