//
//  ResourcesCleanUpError.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourcesCleanUpError: Error {
    
    case failedToDeleteTranslationZipFiles(error: Error)
    case failedToDeleteSHA256Files(errors: [Error])
    case failedToDeleteFavoritedResources(error: Error)
    case failedToDeleteDownloadedLanguages(error: Error)
}
