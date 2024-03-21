//
//  LaunchCountRepository.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import UIKit

class LaunchCountRepository: LaunchCountRepositoryInterface {
    
    static let shared: LaunchCountRepository = LaunchCountRepository()
    
    private let cache: LaunchCountCache = LaunchCountCache()
    
    private var incrementLaunchCountNeeded: Bool = true
    
    private init() {
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleUIApplicationLifeCycleNotification(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func incrementLaunchCountForAppLaunchIfNeeded() {
        
        guard incrementLaunchCountNeeded else {
            return
        }
        
        incrementLaunchCountNeeded = false
        
        let launchCount: Int = cache.getLaunchCountValue()
        
        guard launchCount < Int.max else {
            return
        }
        
        let newLaunchCount: Int = launchCount + 1
        
        cache.storeLaunchCount(launchCount: newLaunchCount)
    }
    
    func getLaunchCountPublisher() -> AnyPublisher<Int, Never> {
        
        incrementLaunchCountForAppLaunchIfNeeded()
        
        return cache.getLaunchCountPublisher()
    }
    
    @objc private func handleUIApplicationLifeCycleNotification(notification: Notification) {
        
        if notification.name == UIApplication.didBecomeActiveNotification {
            
            incrementLaunchCountForAppLaunchIfNeeded()
        }
        else if notification.name == UIApplication.didEnterBackgroundNotification {
            
            incrementLaunchCountNeeded = true
        }
    }
}
