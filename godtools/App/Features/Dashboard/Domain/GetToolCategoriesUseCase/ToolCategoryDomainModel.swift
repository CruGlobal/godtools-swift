//
//  ToolCategoryDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ToolCategoryDomainModel {
    
    let type: ToolCategoryType
    let translatedName: String
    let toolsAvailableText: String
}

extension ToolCategoryDomainModel {
    
    var id: String? {
        
        switch type {
        case .anyCategory:
            return nil
        case .category(let id):
            return id
        }
    }
}
