//
//  FakeDateService.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

final class FakeDateService: DateServiceInterface {
    
    init() {
        
    }
    
    func getCurrentYear(options: CalendarOptions) -> Int? {
        return 1990
    }
}
