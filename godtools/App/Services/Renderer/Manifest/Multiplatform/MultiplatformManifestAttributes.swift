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
        // TODO: Need to set this. ~Levi
        return nil
    }
    
    var backgroundImageAlignments: [MobileContentBackgroundImageAlignment] {
        // TODO: Need to set this. ~Levi
        return []
    }
    
    var backgroundImageScale: MobileContentBackgroundImageScale {
        // TODO: Need to set this. ~Levi
        return .fill
    }
    
    var categoryLabelColor: String? {
        // TODO: Need to set this. ~Levi
        return nil
    }
    
    var dismissListeners: [String] {
        // TODO: Need to set this. ~Levi
        return []
    }
    
    var locale: String? {
        // TODO: Need to set this. ~Levi
        return nil
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
        // TODO: Need to set this. ~Levi
        return MobileContentTextScale(textScaleString: nil)
    }
    
    var tool: String? {
        // TODO: Need to set this. ~Levi
        return nil
    }
    
    var type: String? {
        // TODO: Need to set this. ~Levi
        return nil
    }
}
