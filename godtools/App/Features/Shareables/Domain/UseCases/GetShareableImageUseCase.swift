//
//  GetShareableImageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

final class GetShareableImageUseCase {
    
    private let resourcesFileCache: ResourcesFileCache
    
    init(resourcesFileCache: ResourcesFileCache) {
        
        self.resourcesFileCache = resourcesFileCache
    }
    
    func execute(shareable: ShareableDomainModel) throws -> ShareableImageDomainModel? {
        
        guard !shareable.imageName.isEmpty else {
            throw NSError.errorWithDescription(description: "Failed to get shareable image.  Image name is empty.")
        }
        
        let fileCacheLocation = FileCacheLocation(relativeUrlString: shareable.imageName)
        
        let imageData: Data? = try resourcesFileCache.cache.getData(location: fileCacheLocation)
       
        guard let imageData = imageData else {
            return nil
        }
        
        return ShareableImageDomainModel(
            dataModelId: shareable.imageName,
            imageData: imageData
        )
    }
}
