//
//  MobileContentImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import UIKit
import GodToolsShared

final class MobileContentImageViewModel: MobileContentViewModel {
    
    private let imageModel: Image
    
    private var image: UIImage?
    
    private(set) var imageSize: CGSize?

    let mobileContentAnalytics: MobileContentRendererAnalytics
    let imageWidth: MobileContentViewWidth
    
    init(
        imageModel: Image,
        renderedPageContext: MobileContentRenderedPageContext,
        mobileContentAnalytics: MobileContentRendererAnalytics
    ) {
        
        self.imageModel = imageModel
        self.mobileContentAnalytics = mobileContentAnalytics
        self.imageWidth = MobileContentViewWidth(dimension: imageModel.width)
             
        super.init(
            baseModel: imageModel,
            renderedPageContext: renderedPageContext,
            mobileContentAnalytics: mobileContentAnalytics
        )
    }
    
    func getImage() async -> UIImage? {
        
        if let image = self.image {
            return image
        }
        
        guard let resource = imageModel.resource, let location = resource.toSHA256FileLocation() else {
            return nil
        }
        
        let image: UIImage? = await renderedPageContext.resourcesFileCache.cache.getUIImageNonThrowing(location: location)
        
        self.image = image
        imageSize = image?.size
        
        return image
    }
}
