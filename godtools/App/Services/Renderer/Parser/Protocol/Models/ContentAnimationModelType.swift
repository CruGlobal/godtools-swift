//
//  ContentAnimationModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentAnimationModelType: MobileContentRenderableModel {
    
    var resource: String? { get }
    var autoPlay: Bool { get }
    var loop: Bool { get }
    var events: [MultiplatformEventId] { get }
    var playListeners: [MultiplatformEventId] { get }
    var stopListeners: [MultiplatformEventId] { get }
}

extension ContentAnimationModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
