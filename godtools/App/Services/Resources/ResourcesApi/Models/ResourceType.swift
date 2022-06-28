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
    case chooseYourOwnAdventure = "cyoa"
    case lesson = "lesson"
    case metaTool = "metatool"
    case tract = "tract"
    case unknown = "unknown"
}

extension ResourceType {
    
    var isToolType: Bool {
        switch self {
        case .article, .chooseYourOwnAdventure, .metaTool, .tract:
            return true
            
        case .lesson, .unknown:
            return false
        }
    }
}
