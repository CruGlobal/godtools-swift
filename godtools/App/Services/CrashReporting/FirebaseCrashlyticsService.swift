//
//  FirebaseCrashlyticsService.swift
//  godtools
//
//  Created by Levi Eggert on 12/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

class FirebaseCrashlyticsService: CrashReportingType {
    
    required init() {
        
    }
    
    func testCrash() {
        
        fatalError()
    }
}
