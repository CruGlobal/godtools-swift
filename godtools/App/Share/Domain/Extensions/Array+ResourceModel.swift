//
//  Array+ResourceModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

extension Array where Element == ResourceModel {
    
    typealias ResourceFilter = (ResourceModel) -> Bool
    
    func filterForToolTypes(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        return self.filter { resource in
            
            if let additionalFilter = additionalFilter, additionalFilter(resource) == false {
                return false
            }
            
            return resource.isToolType && resource.isHidden == false
        }
    }
    
    func filterForLessonTypes(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        return self.filter { resource in
            
            if let additionalFilter = additionalFilter, additionalFilter(resource) == false {
                return false
            }
            
            return resource.isLessonType && resource.isHidden == false
        }
    }
}
