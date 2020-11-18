//
//  MobileContentBackgroundImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentBackgroundImageViewModel {
    
    private let backgroundImageNode: BackgroundImageNodeType
    private let manifestResourcesCache: ManifestResourcesCache
    
    let align: MobileContentBackgroundImageAlignType
    let scale: MobileContentBackgroundImageScaleType
    
    required init(backgroundImageNode: BackgroundImageNodeType, manifestResourcesCache: ManifestResourcesCache) {
        
        self.backgroundImageNode = backgroundImageNode
        self.manifestResourcesCache = manifestResourcesCache
        
        align = MobileContentBackgroundImageAlignType(rawValue: backgroundImageNode.backgroundImageAlign) ?? .center
        scale = MobileContentBackgroundImageScaleType(rawValue: backgroundImageNode.backgroundImageScaleType) ?? .fillHorizontally
    }
    
    var backgroundImage: UIImage? {
        guard let resource = backgroundImageNode.backgroundImage else {
            return nil
        }
        return manifestResourcesCache.getImage(resource: resource)
    }
}
