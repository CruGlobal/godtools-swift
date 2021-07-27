//
//  MultiplatformManifest.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformManifest: MobileContentManifestType {
    
    private let manifest: Manifest
    
    let attributes: MobileContentManifestAttributesType
    let title: String? = nil // TODO: Set this. ~Levi
    let pages: [MobileContentManifestPageType] = Array() // TODO: Set this. ~Levi
    let tips: [TipId : MobileContentManifestTipType] = Dictionary() // TODO: Set this. ~Levi
    let resources: [ResourceFilename : MobileContentManifestResourceType] = Dictionary() // TODO: Set this. ~Levi
    
    required init(manifest: Manifest) {
        
        self.manifest = manifest
        self.attributes = MultiplatformManifestAttributes(manifest: manifest)
    }
}
