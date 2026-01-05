//
//  PersonalizedToolToggleInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct PersonalizedToolToggleInterfaceStringsDomainModel {
    
    let personalizedText: String
    let allToolsText: String
    let allLessonsText: String
    
    static var emptyValue: PersonalizedToolToggleInterfaceStringsDomainModel {
        return .init(personalizedText: "", allToolsText: "All Tools", allLessonsText: "All Lessons")
    }
}
