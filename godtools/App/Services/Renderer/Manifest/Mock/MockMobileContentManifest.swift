//
//  MockMobileContentManifest.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MockMobileContentManifest: MobileContentManifestType {
    
    private let resources: [String : MobileContentManifestResourceType] = Dictionary()
    
    let attributes: MobileContentManifestAttributesType = MockMobileContentManifestAttributes()
    let title: String? = nil
    let pages: [MobileContentManifestPageType] = Array()
    let tips: [TipId : MobileContentManifestTipType] = Dictionary()
    
    required init() {
        
    }
    
    func getResource(fileName: String) -> MobileContentManifestResourceType? {
        
        return nil
    }
}
