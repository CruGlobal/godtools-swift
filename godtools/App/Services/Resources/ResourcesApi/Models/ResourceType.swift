//
//  ResourceType.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum ResourceType: String {

    case article = "article"
    case tract = "tract"
    case unknown = "unknown"
    
    static func resourceType(resource: ResourceModel) -> ResourceType {
        
        if let resourceType = ResourceType(rawValue: resource.resourceType) {
            return resourceType
        }
        
        return .unknown
    }
}
