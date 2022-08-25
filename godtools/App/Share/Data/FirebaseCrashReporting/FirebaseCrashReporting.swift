//
//  FirebaseCrashReporting.swift
//  godtools
//
//  Created by Levi Eggert on 8/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

class FirebaseCrashReporting {
    
    init() {
        
    }
    
    func recordError(error: Error) {
        
        Crashlytics.crashlytics().record(error: error)
    }
}
