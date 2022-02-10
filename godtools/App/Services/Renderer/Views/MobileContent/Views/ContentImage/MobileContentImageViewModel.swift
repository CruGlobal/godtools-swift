//
//  MobileContentImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentImageViewModel: MobileContentImageViewModelType {
    
    private let imageModel: ContentImageModelType
    private let rendererPageModel: MobileContentRendererPageModel
    
    let image: UIImage?
    let imageWidth: MobileContentViewWidth
    
    required init(imageModel: ContentImageModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.imageModel = imageModel
        self.rendererPageModel = rendererPageModel
        self.imageWidth = MobileContentViewWidth(dimension: imageModel.width)
        
        if let imageResource = imageModel.resource, !imageResource.isEmpty, let cachedImage = rendererPageModel.resourcesCache.getImageFromManifestResources(fileName: imageResource) {
            self.image = cachedImage
        }
        else {
            self.image = nil
        }
    }
    
    var imageEvents: [MultiplatformEventId] {
        return imageModel.events
    }
    
    var rendererState: MobileContentMultiplatformState {
        return rendererPageModel.rendererState
    }
}
