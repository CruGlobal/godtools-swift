//
//  MobileContentRendererManifestResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class MobileContentRendererManifestResourcesCache {
    
    private let resourcesFileCache: ResourcesSHA256FileCache
        
    init(resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.resourcesFileCache = resourcesFileCache
    }
    
    private func getSHA256FileLocation(resource: Resource) -> FileCacheLocation? {
        
        guard let localName = resource.localName else {
            return nil
        }
        
        return FileCacheLocation(relativeUrlString: localName)
    }
    
    func getFile(resource: Resource) throws -> URL {
        
        guard let location = getSHA256FileLocation(resource: resource) else {
            
            let error = NSError(
                domain: "",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to find file."]
            )
            
            throw error
        }
        
        return try resourcesFileCache.getFile(location: location)
    }
    
    func getUIImage(resource: Resource) throws -> UIImage? {
        
        guard let location = getSHA256FileLocation(resource: resource) else {
            return nil
        }
        
        return try resourcesFileCache.getUIImage(location: location)
    }
    
    func getNonThrowingUIImage(resource: Resource) -> UIImage? {
        
        guard let location = getSHA256FileLocation(resource: resource) else {
            return nil
        }
        
        do {
            return try resourcesFileCache.getUIImage(location: location)
        }
        catch let error {
            print("\n WARNING: Failed to get resource image: \(location.filenameWithPathExtension ?? "")")
            return nil
        }
    }
}
