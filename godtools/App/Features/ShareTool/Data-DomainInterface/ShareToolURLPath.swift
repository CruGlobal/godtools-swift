//
//  ShareToolURLPath.swift
//  godtools
//
//  Created by Rachael Skeath on 11/18/25.
//  Copyright © 2025 Cru. All rights reserved.
//

enum ShareToolURLPath: String {
    case tract = "tool/v1"
    case cyoa = "tool/v2"
    case lesson = "lesson"
    
    init(resourceType: ResourceType) {
        switch resourceType {
        case .chooseYourOwnAdventure:
            self = .cyoa
        case .lesson:
            self = .lesson
        default:
            self = .tract
        }
    }
}
