//
//  MobileContentImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared
import RealmSwift

class MobileContentImageViewModel: MobileContentViewModel {
    
    private let imageModel: Image

    let mobileContentAnalytics: MobileContentRendererAnalytics
    let image: UIImage?
    let imageWidth: MobileContentViewWidth
    
    init(imageModel: Image, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.imageModel = imageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.imageWidth = MobileContentViewWidth(dimension: imageModel.width)
             
        if let resource = imageModel.resource, let cachedImage = renderedPageContext.resourcesCache.getNonThrowingUIImage(resource: resource) {
            image = cachedImage
        }
        else {
            image = nil
        }
        
        super.init(baseModel: imageModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
