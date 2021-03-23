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
    private let languageDirection: LanguageDirection
    
    required init(imageNode: ContentImageNode, pageModel: MobileContentRendererPageModel) {
        
        self.imageNode = imageNode
        self.pageModel = pageModel
        self.languageDirection = pageModel.language.languageDirection
    }
    
    var image: UIImage? {
        
        guard let resource = imageNode.resource else {
            return nil
        }
        
        guard let resourceImage = pageModel.resourcesCache.getImage(resource: resource) else {
            return nil
        }
        
        switch languageDirection {
        case .leftToRight:
            return resourceImage
        case .rightToLeft:
            return resourceImage.imageFlippedForRightToLeftLayoutDirection()
        }
    }
    
    var imageSemanticContentAttribute: UISemanticContentAttribute {
        switch languageDirection {
        case .leftToRight:
            return .forceLeftToRight
        case .rightToLeft:
            return .forceRightToLeft
        }
    }
    
    var imageEvents: [String] {
        return imageNode.events
    }
}
