//
//  DateServiceInterface.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol DateServiceInterface: Sendable {
    
    func getCurrentYear(options: CalendarOptions) -> Int?
}
