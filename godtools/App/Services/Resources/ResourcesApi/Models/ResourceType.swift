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
    case tract = "tract"
    case unknown = "unknown"
}

extension ResourceType {
    
    var isNotLesson: Bool {
        switch self {
        case .article, .chooseYourOwnAdventure, .tract:
            return true
            
        case .lesson, .unknown:
            return false
        }
    }
}
