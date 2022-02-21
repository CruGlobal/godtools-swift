//
//  MultiplatformManifestAttributes.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformManifestAttributes: MobileContentManifestAttributesType {
    
    private let manifest: Manifest
    
    required init(manifest: Manifest) {
        
        self.manifest = manifest
    }
    
    var backgroundColor: MobileContentColor {
        return MobileContentColor(color: manifest.backgroundColor)
    }
    
    var backgroundImage: String? {
        manifest.backgroundImage?.name
    }
    
    var backgroundImageAlignment: MobileContentImageAlignmentType {
        return MultiplatformImageAlignment(imageGravity: manifest.backgroundImageGravity)
    }
    
    var backgroundImageScale: ImageScaleType {
        return manifest.backgroundImageScaleType
    }
    
    var categoryLabelColor: MobileContentColor? {
        return MobileContentColor(color: manifest.categoryLabelColor)
    }
    
    var dismissListeners: [MultiplatformEventId] {
        return manifest.dismissListeners.map({MultiplatformEventId(eventId: $0)})
    }
    
    var locale: String? {
        return manifest.locale?.description
    }
    
    var navbarColor: MobileContentColor? {
        return MobileContentColor(color: manifest.navBarColor)
    }
    
    var navbarControlColor: MobileContentColor? {
        return MobileContentColor(color: manifest.navBarControlColor)
    }
    
    var primaryColor: MobileContentColor {
        return MobileContentColor(color: manifest.primaryColor)
    }
    
    var primaryTextColor: MobileContentColor {
        return MobileContentColor(color: manifest.primaryTextColor)
    }
    
    var textColor: MobileContentColor {
        return MobileContentColor(color: manifest.textColor)
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(doubleValue: manifest.textScale)
    }
}
