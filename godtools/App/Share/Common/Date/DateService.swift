//
//  DateService.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class DateService: DateServiceInterface {
    
    let calendar: Calendar?
    
    init(calendar: Calendar? = nil) {
        
        self.calendar = calendar
    }
    
    func getCurrentYear(options: CalendarOptions) -> Int? {
        
        let options: CalendarOptions = options.copy(calendar: calendar)
                
        let todaysDate: Date = Date()
        let todaysYearComponents: DateComponents = options.calendar.dateComponents([.year], from: todaysDate)
        
        return todaysYearComponents.year
    }
}
