//
//  GodToolsParserLogger.swift
//  godtools
//
//  Created by Levi Eggert on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class GodToolsParserLogger {
    
    static let shared: GodToolsParserLogger = GodToolsParserLogger()
    
    private var isStarted: Bool = false
    
    private init() {
        
    }
    
    func start(firebaseCrashReporting: FirebaseCrashReporting) {
        
        guard !isStarted else {
            return
        }
        
        isStarted = true
                
        NapierProxyKt.enableCustomLogging { (logLevel: NapierLogLevel, tag: String?, throwable: KotlinThrowable?, message: String?) in
            
            guard let error = throwable?.asError() else {
                return
            }
            
            firebaseCrashReporting.recordError(error: error)
        }
    }
}
