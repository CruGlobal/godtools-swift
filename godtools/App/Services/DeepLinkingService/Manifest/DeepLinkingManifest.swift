//
//  DeepLinkingManifest.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DeepLinkingManifest {
    
    let parserManifests: [DeepLinkingParserManifestType]
    
    required init(parserManifests: [DeepLinkingParserManifestType]) {
        
        self.parserManifests = parserManifests
    }
}
