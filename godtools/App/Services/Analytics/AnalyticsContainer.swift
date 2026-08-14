//
//  AnalyticsContainer.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

final class AnalyticsContainer: Sendable {
     
    // analytics systems
    let firebaseAnalytics: FirebaseAnalyticsInterface

    // shared analytics tracking
    let trackActionAnalytics: TrackActionAnalytics
            
    init(firebaseAnalytics: FirebaseAnalyticsInterface) {
                
        trackActionAnalytics = TrackActionAnalytics(firebaseAnalytics: firebaseAnalytics)

        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func trackScreenView(properties: AnalyticsProperties) async {
        
        await firebaseAnalytics.trackScreenView(properties: properties)
    }
    
    func trackAction(properties: AnalyticsProperties, actionName: String, data: [String: Any]?) async {
        
        await firebaseAnalytics.trackAction(
            properties: properties,
            actionName: actionName,
            data: data
        )
    }
    
    func trackExitLink(properties: AnalyticsProperties, url: URL) async {
        
        await firebaseAnalytics.trackExitLink(
            properties: properties,
            url: url.absoluteString
        )
    }
}
