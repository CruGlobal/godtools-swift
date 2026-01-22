//
//  GetShareableImageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import GodToolsShared

class GetShareableImageRepository {
    
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    init(resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.resourcesFileCache = resourcesFileCache
    }
    
    func getImageDomainModel(shareable: ShareableDomainModel) throws -> ShareableImageDomainModel? {
        
        guard !shareable.imageName.isEmpty else {
            return nil
        }
        
        let fileCacheLocation = FileCacheLocation(relativeUrlString: shareable.imageName)
        
        let imageData: Data? = try resourcesFileCache.getData(location: fileCacheLocation)
        
        guard let imageData = imageData else {
            return nil
        }
        
        return ShareableImageDomainModel(
            dataModelId: shareable.imageName,
            imageData: imageData
        )
    }
}
