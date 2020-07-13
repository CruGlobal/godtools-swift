//
//  ResourcesDownloaderResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesDownloaderResult {
    
    let languages: [LanguageModel]
    let resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel
    
    required init(languages: [LanguageModel], resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) {
        
        self.languages = languages
        self.resourcesPlusLatestTranslationsAndAttachments = resourcesPlusLatestTranslationsAndAttachments
    }
}
