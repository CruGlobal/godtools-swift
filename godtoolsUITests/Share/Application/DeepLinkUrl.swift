//
//  DeepLinkUrl.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct DeepLinkUrl {
    
    private static let host: String = "godtools://org.cru.godtools"
    
    static func getDashboardFavorites() -> String {
        return "\(host)/dashboard/favorites"
    }
    
    static func getDashboardLessons() -> String {
        return "\(host)/dashboard/lessons"
    }
    
    static func getDashboardTools() -> String {
        return "\(host)/dashboard/tools"
    }
    
    static func getToolDetails(toolId: String) -> String {
        return "\(host)/ui_tests/tooldetails?tool_id=\(toolId)"
    }
}
