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

class MobileContentImageViewModel: MobileContentClickableViewModel {
    
    private let imageModel: Image
    private let mobileContentAnalytics: MobileContentAnalytics
    
    let image: UIImage?
    let imageWidth: MobileContentViewWidth
    
    init(imageModel: Image, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.imageModel = imageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.imageWidth = MobileContentViewWidth(dimension: imageModel.width)
                
        if let resource = imageModel.resource, let cachedImage = renderedPageContext.resourcesCache.getUIImage(resource: resource) {
            self.image = cachedImage
        }
        else {
            self.image = nil
        }
        
        super.init(baseModel: imageModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
