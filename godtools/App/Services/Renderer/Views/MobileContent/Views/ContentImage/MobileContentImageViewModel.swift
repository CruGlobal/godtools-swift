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

class MobileContentImageViewModel: MobileContentViewModel, ClickableMobileContentViewModel {
    
    private let imageModel: Image
    private let renderedPageContext: MobileContentRenderedPageContext
    private let mobileContentAnalytics: MobileContentAnalytics
    
    let image: UIImage?
    let imageWidth: MobileContentViewWidth
    
    init(imageModel: Image, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.imageModel = imageModel
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
        self.imageWidth = MobileContentViewWidth(dimension: imageModel.width)
                
        if let resource = imageModel.resource, let cachedImage = renderedPageContext.resourcesCache.getUIImage(resource: resource) {
            self.image = cachedImage
        }
        else {
            self.image = nil
        }
        
        super.init(baseModel: imageModel)
    }
    
    var imageEvents: [EventId] {
        return imageModel.events
    }
    
    var rendererState: State {
        return renderedPageContext.rendererState
    }
    
    func getClickableUrl() -> URL? {
        return getClickableUrl(model: imageModel)
    }
}

// MARK: - Inputs

extension MobileContentImageViewModel {
    
    func imageTapped() {
        trackClickableEvents(model: imageModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
