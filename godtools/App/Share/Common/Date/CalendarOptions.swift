//
//  CalendarOptions.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct CalendarOptions: Sendable {
    
    let calendar: Calendar
    let localeId: String?
    
    init(calendar: Calendar, localeId: String?) {
        
        self.localeId = localeId
        
        var calendarCopy: Calendar = calendar
        
        if let localeId = localeId, !localeId.isEmpty {
            calendarCopy.locale = Locale(identifier: localeId)
        }

        self.calendar = calendarCopy
    }
    
    init(localeId: String) {
        self.init(calendar: Calendar.current, localeId: localeId)
    }
    
    static var defaultOptions: CalendarOptions {
        return CalendarOptions(calendar: Calendar.current, localeId: nil)
    }
    
    func copy(calendar: Calendar? = nil) -> CalendarOptions {
        return CalendarOptions(
            calendar: calendar ?? self.calendar,
            localeId: localeId
        )
    }
}
