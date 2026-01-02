//
//  ToolLanguageAvailabilityDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/16/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ToolLanguageAvailabilityDomainModel {
    
    let availabilityString: String
    let isAvailable: Bool
    
    static var empty: ToolLanguageAvailabilityDomainModel {
        return ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
    }
}
