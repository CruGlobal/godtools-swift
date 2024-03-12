//
//  MobileContentRendererManifestResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentRendererManifestResourcesCache {
    
    private let resourcesFileCache: ResourcesSHA256FileCache
        
    init(resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.resourcesFileCache = resourcesFileCache
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func getSHA256FileLocation(resource: Resource) -> FileCacheLocation? {
        
        guard let localName = resource.localName else {
            return nil
        }
        
        return FileCacheLocation(relativeUrlString: localName)
    }
    
    func getFile(resource: Resource) -> Result<URL, Error> {
        
        guard let location = getSHA256FileLocation(resource: resource) else {
            return .failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to find file."]))
        }
        
        return resourcesFileCache.getFile(location: location)
    }
    
    func getUIImage(resource: Resource) -> UIImage? {
        
        guard let location = getSHA256FileLocation(resource: resource) else {
            return nil
        }
        
        switch resourcesFileCache.getUIImage(location: location) {
        case .success(let uiImage):
            return uiImage
        case .failure( _):
            return nil
        }
    }
}
