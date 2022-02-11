//
//  MultiplatformContentAnimation.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentAnimation {
    
    private let animation: Animation
    
    required init(animation: Animation) {
        
        self.animation = animation
    }
    
    var resource: String? {
        let resourceName: String? = animation.resource?.name
        return resourceName
    }
    
    var autoPlay: Bool {
        return animation.autoPlay
    }
    
    var loop: Bool {
        return animation.loop
    }
    
    var events: [MultiplatformEventId] {
        return animation.events.map({MultiplatformEventId(eventId: $0)})
    }
    
    var playListeners: [MultiplatformEventId] {
        return animation.playListeners.map({MultiplatformEventId(eventId: $0)})
    }
    
    var stopListeners: [MultiplatformEventId] {
        return animation.stopListeners.map({MultiplatformEventId(eventId: $0)})
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentAnimation {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        
        return Array()
    }
}
