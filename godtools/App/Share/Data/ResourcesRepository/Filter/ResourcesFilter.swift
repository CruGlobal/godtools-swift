//
//  ResourcesFilter.swift
//  godtools
//
//  Created by Levi Eggert on 11/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ResourcesFilter {
    
    let category: String?
    let languageCode: String?
    let resourceTypes: [ResourceType]?
    let isHidden: Bool?
    let variants: ResourcesFilterVariant?
    
    init(category: String? = nil, languageCode: String? = nil, resourceTypes: [ResourceType]? = nil, isHidden: Bool? = false, variants: ResourcesFilterVariant? = nil) {
        
        self.category = category
        self.languageCode = languageCode
        self.resourceTypes = resourceTypes
        self.isHidden = isHidden
        self.variants = variants
    }
}
