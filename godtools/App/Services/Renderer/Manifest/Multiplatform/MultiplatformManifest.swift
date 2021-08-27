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
    let title: String?
    let pages: [MobileContentManifestPageType] = Array() // TODO: Set this. ~Levi
    let tips: [TipId : MobileContentManifestTipType] = Dictionary() // TODO: Set this. ~Levi
    
    required init(manifest: Manifest) {
        
        self.manifest = manifest
        self.attributes = MultiplatformManifestAttributes(manifest: manifest)
        self.title = manifest.title
    }
    
    func getResource(fileName: String) -> MobileContentManifestResourceType? {
        
        guard let resource = manifest.resources[fileName] else {
            return nil
        }
        
        return MultiplatformManifestResource(resource: resource)
    }
}
