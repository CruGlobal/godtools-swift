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
    private let pageModel: MobileContentRendererPageModel
    
    required init(imageModel: ContentImageModelType, pageModel: MobileContentRendererPageModel) {
        
        self.imageModel = imageModel
        self.pageModel = pageModel
    }
    
    var image: UIImage? {
        
        guard let resource = imageModel.resource else {
            return nil
        }
        
        return pageModel.resourcesCache.getImage(resource: resource)
    }
    
    var imageEvents: [String] {
        return imageModel.events
    }
}
