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
    
    static let toolTypes: [ResourceType] = [.article, .chooseYourOwnAdventure, .tract]
    
    var isToolType: Bool {
        return ResourceType.toolTypes.contains(self)
    }
    
    var isLessonType: Bool {
        switch self {
        case .lesson:
            return true
            
        default:
            return false
        }
    }
}
