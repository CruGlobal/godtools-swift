//
//  ResourcesLatestTranslationsFileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResourcesLatestTranslationsFileCacheLocation: ZipFileContentsCacheLocationType {
        
    let relativeUrl: URL?
    
    init(godToolsResource: GodToolsResource) {
        
        relativeUrl = URL(string: godToolsResource.resourceId)?.appendingPathComponent(godToolsResource.languageCode).appendingPathComponent("translation_contents")
    }
}
