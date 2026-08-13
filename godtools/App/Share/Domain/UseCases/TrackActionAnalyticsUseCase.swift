//
//  TrackActionAnalyticsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class TrackActionAnalyticsUseCase: Sendable {
    
    private let analytics: AnalyticsContainer
        
    init(analytics: AnalyticsContainer) {
        
        self.analytics = analytics
    }
    
    func trackAction(properties: AnalyticsProperties, actionName: String, data: [String: Any]?) async {
        
        await analytics.trackAction(properties: properties, actionName: actionName, data: data)
    }
}
