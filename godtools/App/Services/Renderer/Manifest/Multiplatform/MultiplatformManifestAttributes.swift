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
    
    var backgroundColor: UIColor {
        return manifest.backgroundColor
    }
    
    var backgroundImage: String? {
        // TODO: Need to set this. ~Levi
        return nil
    }
    
    var backgroundImageAlign: [String] {
        // TODO: Need to set this. ~Levi
        return []
    }
    
    var backgroundImageScaleType: String {
        // TODO: Need to set this. ~Levi
        return ""
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
    
    var navbarColor: UIColor? {
        return manifest.navBarColor
    }
    
    var navbarControlColor: UIColor? {
        return manifest.navBarControlColor
    }
    
    var primaryColor: UIColor {
        return manifest.primaryColor
    }
    
    var primaryTextColor: UIColor {
        return manifest.primaryTextColor
    }
    
    var textColor: UIColor {
        return manifest.textColor
    }
    
    var textScale: String? {
        // TODO: Need to set this. ~Levi
        return nil
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
