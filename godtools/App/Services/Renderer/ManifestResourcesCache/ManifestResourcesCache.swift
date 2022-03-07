//
//  ManifestResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ManifestResourcesCache {
    
    private let manifest: Manifest
    private let translationsFileCache: TranslationsFileCache
    
    required init(manifest: Manifest, translationsFileCache: TranslationsFileCache) {
        
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
    }
    
    private func getSHA256FileLocation(fileName: String) -> SHA256FileLocation? {
        
        guard let localeName = manifest.resources[fileName]?.localName else {
            return nil
        }
        
        let location: SHA256FileLocation = SHA256FileLocation(sha256WithPathExtension: localeName)
        
        return location
    }
    
    func getFile(fileName: String) -> Result<URL, Error> {
        
        guard let location = getSHA256FileLocation(fileName: fileName) else {
            return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to find file."]))
        }
        
        return translationsFileCache.getFile(location: location)
    }
    
    func getImageFromManifestResources(resource: Resource) -> UIImage? {
        
        guard let resourceName = resource.name, !resourceName.isEmpty else {
            return nil
        }
        
        guard let location = getSHA256FileLocation(fileName: resourceName) else {
            return nil
        }
        
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
