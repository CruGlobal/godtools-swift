//
//  ManifestResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ManifestResourcesCache {
    
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    
    required init(manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache) {
        
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
    }
    
    func getImage(resource: String) -> UIImage? {
        
        guard let resourceSrc = manifest.resources[resource]?.src else {
            return nil
        }
        
        guard let resourceImage = translationsFileCache.getImage(location: SHA256FileLocation(sha256WithPathExtension: resourceSrc)) else {
            return nil
        }
        
        return resourceImage
    }
}
