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
        
        let location: SHA256FileLocation = SHA256FileLocation(sha256WithPathExtension: resourceSrc)
        
        let imageData: Data?
        
        switch translationsFileCache.getData(location: location) {
            
        case .success(let data):
            imageData = data
        case .failure( _):
            imageData = nil
        }
        
        if let imageData = imageData, let image = UIImage(data: imageData) {
                                        
            return image
        }
        
        return nil
    }
}
