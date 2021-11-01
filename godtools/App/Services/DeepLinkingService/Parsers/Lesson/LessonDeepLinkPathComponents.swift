//
//  LessonDeepLinkPathComponents.swift
//  godtools
//
//  Created by Levi Eggert on 11/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct LessonDeepLinkPathComponents {
    
    let abbreviation: String?
    let primaryLanguageCode: String?
    
    init(pathComponents: [String]) {
        
        if pathComponents.count > 1 {
            abbreviation = pathComponents[1]
        }
        else {
            abbreviation = nil
        }
        
        if pathComponents.count > 2 {
            primaryLanguageCode = pathComponents[2]
        }
        else {
            primaryLanguageCode = nil
        }
    }
}
