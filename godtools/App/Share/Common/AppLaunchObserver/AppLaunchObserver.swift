//
//  AppLaunchObserver.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

class AppLaunchObserver {
        
    private var resignedActiveDate: Date?
    private var appIsInBackground: Bool = false
    
    private(set) var appLaunched: Bool = false
    
    init() {

    }
    
    func onAppLaunchPublisher() -> AnyPublisher<AppLaunchState, Never> {
        
        return Publishers.Merge3(
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
            NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification),
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
        )
        .map { (notification: Notification) in
                        
            let launchState: AppLaunchState
            
            if notification.name == UIApplication.willResignActiveNotification {
                                
                launchState = .inBackground
                
                self.resignedActiveDate = Date()
            }
            else if notification.name == UIApplication.didEnterBackgroundNotification {
                                
                launchState = .inBackground
                
                self.appIsInBackground = true
            }
            else if notification.name == UIApplication.didBecomeActiveNotification {
                                
                let appLaunchedFromTerminatedState: Bool = !self.appLaunched
                let appLaunchedFromBackgroundState: Bool = self.appLaunched && self.appIsInBackground
                
                if appLaunchedFromTerminatedState {
                                        
                    launchState = .fromTerminatedState
                    
                    self.appLaunched = true
                }
                else if appLaunchedFromBackgroundState {
                                        
                    self.appIsInBackground = false
                    
                    let currentDate: Date = Date()
                    let secondsInBackground: TimeInterval
                    
                    if let resignedActiveDate = self.resignedActiveDate {
                        secondsInBackground = currentDate.timeIntervalSince(resignedActiveDate)
                    }
                    else {
                        secondsInBackground = 0
                    }
                    
                    launchState = .fromBackgroundState(secondsInBackground: secondsInBackground)
                    
                    self.resignedActiveDate = nil
                }
                else {
                    
                    launchState = .notDetermined
                }
            }
            else {
                
                launchState = .notDetermined
            }
            
            return launchState
        }
        .eraseToAnyPublisher()
    }
}
