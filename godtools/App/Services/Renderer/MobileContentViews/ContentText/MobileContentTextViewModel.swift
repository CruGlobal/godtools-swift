//
//  MobileContentTextViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTextViewModel: MobileContentTextViewModelType {
    
    private let contentTextNode: ContentTextNode
    private let manifestResourcesCache: ManifestResourcesCache
        
    required init(contentTextNode: ContentTextNode, manifestResourcesCache: ManifestResourcesCache) {
        
        self.contentTextNode = contentTextNode
        self.manifestResourcesCache = manifestResourcesCache
    }
    
    var startImage: UIImage? {
        
        guard let resource = contentTextNode.startImage, !resource.isEmpty else {
            return nil
        }
        
        guard let resourceImage = manifestResourcesCache.getImage(resource: resource) else {
            return nil
        }
        
        return resourceImage
    }
    
    var text: String? {
        return contentTextNode.text
    }
    
    var endImage: UIImage? {
        
        guard let resource = contentTextNode.endImage, !resource.isEmpty else {
            return nil
        }
        
        guard let resourceImage = manifestResourcesCache.getImage(resource: resource) else {
            return nil
        }
        
        return resourceImage
    }
}
