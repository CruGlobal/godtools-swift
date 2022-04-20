//
//  DashboardDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DashboardDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        if let dashboardPathComponent = pathComponents[safe: 1], let dashboardPath = DashboardDeepLinkDashboardPath(rawValue: dashboardPathComponent) {
            
            switch dashboardPath {
            case .tools:
                return .allToolsList
            case .home:
                return .favoritedToolsList
            case .lessons:
                return .lessonsList
            }
        }
        else if pathComponents.first == DashboardDeepLinkDashboardPath.lessons.rawValue {
            
            return .lessonsList
        }
        
        return nil
    }
}
