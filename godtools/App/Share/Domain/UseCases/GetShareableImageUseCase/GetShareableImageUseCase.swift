//
//  GetShareableImageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class GetShareableImageUseCase {
    
    func getShareableImage(from shareable: Shareable, manifestResourcesCache: ManifestResourcesCache) -> ShareableImageDomainModel? {
        guard let shareableImage = shareable as? ShareableImage, let resource = shareableImage.resource, let imageToShare = manifestResourcesCache.getImageFromManifestResources(resource: resource) else {
            return nil
        }
        
        return ShareableImageDomainModel(
            image: imageToShare,
            imageId: shareable.id,
            toolAbbreviation: shareable.manifest.code
        )
    }
}
