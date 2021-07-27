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
    
    required init(imageModel: ContentImageModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.imageModel = imageModel
        self.rendererPageModel = rendererPageModel
    }
    
    var image: UIImage? {
        
        guard let resource = imageModel.resource else {
            return nil
        }
        
        return rendererPageModel.resourcesCache.getImageFromManifestResources(resource: resource)
    }
    
    var imageEvents: [String] {
        return imageModel.events
    }
}
