//
//  FirebaseNonFatalErrorReporting.swift
//  godtools
//
//  Created by Levi Eggert on 3/2/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

final class FirebaseNonFatalErrorReporting: ErrorReportingInterface {
    
    init() {
        
    }
    
    func log(tag: String, message: String) {
        
        Crashlytics.crashlytics().log("\(tag): \(message)")
    }
    
    func reportError(error: Error) {
        
        Crashlytics.crashlytics().record(error: error)
    }
}
