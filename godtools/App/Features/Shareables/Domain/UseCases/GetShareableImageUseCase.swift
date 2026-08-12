//
//  GetShareableImageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

final class GetShareableImageUseCase: Sendable {
    
    private let resourcesFileCache: ResourcesFileCache
    
    init(resourcesFileCache: ResourcesFileCache) {
        
        self.resourcesFileCache = resourcesFileCache
    }
    
    func execute(shareable: ShareableDomainModel) async throws -> ShareableImageDomainModel? {
        
        guard !shareable.imageName.isEmpty else {
            throw NSError.errorWithDescription(description: "Failed to get shareable image.  Image name is empty.")
        }
        
        let fileCacheLocation = FileCacheLocation(relativeUrlString: shareable.imageName)
        
        let imageData: Data?
       
        do {
            imageData = try await resourcesFileCache.cache.getData(location: fileCacheLocation)
        }
        catch let error {
            imageData = nil
        }
        
        return ShareableImageDomainModel(
            dataModelId: shareable.imageName,
            imageData: imageData
        )
    }
}
