//
//  AppFlow+UserLaunchedApp.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension AppFlow {
    
    func userLaunchedApp(appLaunchedFromTerminatedState: Bool, appLaunchedFromBackgroundState: Bool) {
        
        let numberOfSecondsInBackground: TimeInterval = appDiContainer.appSecondsInBackground.numberOfSecondsInBackground ?? 0
        let fiveMinutes: TimeInterval = 60 * 5
        
        if appLaunchedFromTerminatedState || (appLaunchedFromBackgroundState && numberOfSecondsInBackground >= fiveMinutes) {
         
            let appLaunchCountRepository: AppLaunchCountRepository = appDiContainer.appLaunchCountRepository
            let firebaseAnalytics: FirebaseAnalyticsType = appDiContainer.analytics.firebaseAnalytics
            
            appLaunchCountRepository.incrementAppLaunchCount()
            
            let launchCount: Int64 = appLaunchCountRepository.getAppLaunchCount()
            
            firebaseAnalytics.setUserProperty(userProperty: .godtoolsLaunches, value: String(launchCount))
        }
    }
}
