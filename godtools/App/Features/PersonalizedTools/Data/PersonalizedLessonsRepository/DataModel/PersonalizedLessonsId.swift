//
//  PersonalizedLessonsId.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedLessonsId: Sendable {
    
    let value: String
    
    init(country: String, language: String) {
        
        value = "\(country)_\(language)"
    }
}
