//
//  DashboardPathDeepLinkParser.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DashboardPathDeepLinkParser: DeepLinkUrlParserType {
    
    required init() {
        
    }
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String : Any]) -> ParsedDeepLinkType? {
        
        guard let dashboardPathIndex = pathComponents.firstIndex(of: DashboardDeepLinkDashboardPath.dashboard.rawValue) else {
            return nil
        }
        
        if let dashboardTabPathComponent = pathComponents[safe: dashboardPathIndex + 1], let dashboardTabPath = DashboardDeepLinkDashboardPath(rawValue: dashboardTabPathComponent) {
            
            switch dashboardTabPath {
            case .dashboard:
                return .dashboard
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
        
        return .dashboard
    }
}
