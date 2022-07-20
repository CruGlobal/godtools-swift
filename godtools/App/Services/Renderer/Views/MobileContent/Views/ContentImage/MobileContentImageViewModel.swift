//
//  MobileContentImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import RealmSwift

class MobileContentImageViewModel: MobileContentImageViewModelType {
    
    private let imageModel: Image
    private let renderedPageContext: MobileContentRenderedPageContext
    
    let image: UIImage?
    let imageWidth: MobileContentViewWidth
    
    required init(imageModel: Image, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.imageModel = imageModel
        self.renderedPageContext = renderedPageContext
        self.imageWidth = MobileContentViewWidth(dimension: imageModel.width)
                
        if let resource = imageModel.resource, let cachedImage = renderedPageContext.resourcesCache.getUIImage(resource: resource) {
            self.image = cachedImage
        }
        else {
            self.image = nil
        }
    }
    
    var imageEvents: [EventId] {
        return imageModel.events
    }
    
    var rendererState: State {
        return renderedPageContext.rendererState
    }
}
