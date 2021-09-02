//
//  SecondsInBackground.swift
//  mpdx-ios
//
//  Created by Levi Eggert on 10/15/20.
//  Copyright © 2020 Cru Global, Inc. All rights reserved.
//

import Foundation

class SecondsInBackground {
    
    private let sharedUserDefaults: SharedUserDefaultsCache
    private let resignedActiveDateCacheKey: String
            
    private(set) var numberOfSecondsInBackground: TimeInterval?
    
    required init(sharedUserDefaults: SharedUserDefaultsCache, resignedActiveDateCacheKey: String) {
        
        self.sharedUserDefaults = sharedUserDefaults
        self.resignedActiveDateCacheKey = resignedActiveDateCacheKey
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: UIApplication.willTerminateNotification, object: nil)
        
        calculateNumberOfSecondsInBackgroundIfNeeded()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
    
    private var resignedActiveDate: Date? {
        return sharedUserDefaults.getValue(key: resignedActiveDateCacheKey) as? Date
    }
    
    private func calculateNumberOfSecondsInBackgroundIfNeeded() {
        
        guard numberOfSecondsInBackground == nil else {
            return
        }
        
        if let resignedActiveDate = resignedActiveDate {
            
            let currentDate: Date = Date()
            let elapsedTimeInSeconds: TimeInterval = currentDate.timeIntervalSince(resignedActiveDate)
                  
            numberOfSecondsInBackground = elapsedTimeInSeconds
                                    
            storeLastBackgroundDate()
        }
    }
    
    private func storeLastBackgroundDate() {
        sharedUserDefaults.cache(value: Date(), forKey: resignedActiveDateCacheKey)
        sharedUserDefaults.commitChanges()
    }
}

// MARK: - Notifications

extension SecondsInBackground {
    
    @objc private func handleNotification(notification: Notification) {
        
        if notification.name == UIApplication.willEnterForegroundNotification {
            calculateNumberOfSecondsInBackgroundIfNeeded()
        }
        else if notification.name == UIApplication.willResignActiveNotification {
            numberOfSecondsInBackground = nil
            storeLastBackgroundDate()
        }
        else if notification.name == UIApplication.didEnterBackgroundNotification {
            numberOfSecondsInBackground = nil
            storeLastBackgroundDate()
        }
        else if notification.name == UIApplication.willTerminateNotification {
            numberOfSecondsInBackground = nil
            storeLastBackgroundDate()
        }
    }
}
