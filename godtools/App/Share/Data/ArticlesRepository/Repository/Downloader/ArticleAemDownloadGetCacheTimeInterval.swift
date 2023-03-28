//
//  ArticleAemDownloadGetCacheTimeInterval.swift
//  godtools
//
//  Created by Levi Eggert on 3/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ArticleAemDownloadGetCacheTimeInterval {
    
    init() {
        
    }
    
    func getCacheTimeInterval(cachePolicy: ArticleAemDownloadOperationCachePolicy) -> TimeInterval? {
        
        let calendar: Calendar = Calendar.current
        let currentDate: Date = Date()
        let currentDateComponents: DateComponents = calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: currentDate)
        
        switch cachePolicy {
            
        case .fetchFromCacheUpToNextHour:
            
            guard let currentMinutes = currentDateComponents.minute, let currentSeconds = currentDateComponents.second else {
                return nil
            }
            
            let minutesUpToNextHour: Int = 60 - currentMinutes
            
            var dateUpToNextHourComponents: DateComponents = DateComponents()
            dateUpToNextHourComponents.minute = minutesUpToNextHour
            dateUpToNextHourComponents.second = currentSeconds * -1
            
            guard let dateUpToNextHour = calendar.date(byAdding: dateUpToNextHourComponents, to: currentDate) else {
                return nil
            }
            
            let timeInterval: TimeInterval = dateUpToNextHour.timeIntervalSince1970
            
            return timeInterval
            
        case .ignoreCache:
            return nil
        }
    }
}
