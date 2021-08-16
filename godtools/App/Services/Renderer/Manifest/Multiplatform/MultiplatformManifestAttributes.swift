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
        manifest.backgroundImage?.localName
    }
    
    var backgroundImageAlignments: [MobileContentBackgroundImageAlignment] {
        // TODO: Need to set this. ~Levi
        return []
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        // TODO: Need to set this. ~Levi
        return .fill
    }
    
    var categoryLabelColor: MobileContentColor? {
        return MobileContentColor(color: manifest.categoryLabelColor)
    }
    
    var dismissListeners: [String] {
        return manifest.dismissListeners.map({$0.description()})
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
