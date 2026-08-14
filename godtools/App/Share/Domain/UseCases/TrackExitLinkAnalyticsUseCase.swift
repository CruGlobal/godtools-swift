//
//  TrackExitLinkAnalyticsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class TrackExitLinkAnalyticsUseCase: Sendable {
    
    private let analytics: AnalyticsContainer
        
    init(analytics: AnalyticsContainer) {
        
        self.analytics = analytics
    }
    
    func execute(properties: AnalyticsProperties, url: URL) async {
        
        await analytics.trackExitLink(
            properties: properties,
            url: url
        )
    }
}
