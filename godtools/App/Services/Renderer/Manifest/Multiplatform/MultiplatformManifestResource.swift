//
//  MultiplatformManifestResource.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

struct MultiplatformManifestResource: MobileContentManifestResourceType {
    
    let filename: String
    let src: String
    
    init(resource: Resource) {
        
        self.filename = resource.name ?? ""
        self.src = resource.localName ?? ""
    }
}
