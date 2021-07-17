//
//  MockMobileContentManifest.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MockMobileContentManifest: MobileContentManifestType {
    
    let attributes: MobileContentManifestAttributesType = MockMobileContentManifestAttributes()
    let title: String? = nil
    let pages: [MobileContentManifestPageType] = Array()
    let tips: [TipId : MobileContentManifestTipType] = Dictionary()
    let resources: [ResourceFilename : MobileContentManifestResourceType] = Dictionary()
    
    required init() {
        
    }
}
