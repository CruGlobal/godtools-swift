//
//  MobileContentImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentImageViewModel: MobileContentImageViewModelType {
    
    private let imageModel: ContentImageModelType
    private let rendererPageModel: MobileContentRendererPageModel
    
    let image: UIImage?
    let imageConstraintsType: MobileContentImageConstraintsType?
    
    required init(imageModel: ContentImageModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.imageModel = imageModel
        self.rendererPageModel = rendererPageModel
        
        if let imageResource = imageModel.resource, !imageResource.isEmpty, let cachedImage = rendererPageModel.resourcesCache.getImageFromManifestResources(fileName: imageResource) {
            
            self.image = cachedImage
                        
            if imageModel.width > 0 {
                imageConstraintsType = .fixedWidthAndHeight(size: CGFloat(imageModel.width))
            }
            else {
                imageConstraintsType = .aspectRatio(multiplier: cachedImage.size.height / cachedImage.size.width)
            }
        }
        else {
            
            self.image = nil
            self.imageConstraintsType = nil
        }
    }
    
    var imageEvents: [MultiplatformEventId] {
        return imageModel.events
    }
    
    var rendererState: MobileContentMultiplatformState {
        return rendererPageModel.rendererState
    }
}
