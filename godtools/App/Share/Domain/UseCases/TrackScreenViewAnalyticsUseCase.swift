//
//  TrackScreenViewAnalyticsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class TrackScreenViewAnalyticsUseCase: Sendable {
    
    private let analytics: AnalyticsContainer
        
    init(analytics: AnalyticsContainer) {
        
        self.analytics = analytics
    }
    
    func execute(properties: AnalyticsProperties) async {

        await analytics.trackScreenView(properties: properties)
    }
}
