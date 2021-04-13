//
//  MobileContentImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentImageViewModel: MobileContentImageViewModelType {
    
    private let imageNode: ContentImageNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(imageNode: ContentImageNode, pageModel: MobileContentRendererPageModel) {
        
        self.imageNode = imageNode
        self.pageModel = pageModel
    }
    
    var image: UIImage? {
        
        guard let resource = imageNode.resource else {
            return nil
        }
        
        return pageModel.resourcesCache.getImage(resource: resource)
    }
    
    var imageEvents: [String] {
        return imageNode.events
    }
}
