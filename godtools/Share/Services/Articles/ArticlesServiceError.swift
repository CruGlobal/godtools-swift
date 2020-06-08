//
//  ArticlesServiceError.swift
//  godtools
//
//  Created by Levi Eggert on 5/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ArticlesServiceError: Error {
    
    case aemImportServiceError(error: ArticleAemImportServiceError)
    case fetchManifestError(error: ResourcesLatestTranslationServicesError)
    case unknownError(error: Error)
}
