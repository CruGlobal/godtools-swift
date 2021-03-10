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
    private let mobileContentEvents: MobileContentEvents
    private let manifestResourcesCache: ManifestResourcesCache
    private let languageDirection: LanguageDirection
    
    required init(imageNode: ContentImageNode, mobileContentEvents: MobileContentEvents, manifestResourcesCache: ManifestResourcesCache, languageDirection: LanguageDirection) {
        
        self.imageNode = imageNode
        self.mobileContentEvents = mobileContentEvents
        self.manifestResourcesCache = manifestResourcesCache
        self.languageDirection = languageDirection
    }
    
    var image: UIImage? {
        
        guard let resource = imageNode.resource else {
            return nil
        }
        
        guard let resourceImage = manifestResourcesCache.getImage(resource: resource) else {
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
    
    func imageTapped() {
        
        for event in imageNode.events {
            mobileContentEvents.eventImageTapped(eventImage: ImageEvent(event: event))
        }
    }
}
