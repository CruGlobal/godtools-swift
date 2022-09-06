//
//  GodToolsParserLogger.swift
//  godtools
//
//  Created by Levi Eggert on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import FirebaseCrashlytics

class GodToolsParserLogger {
    
    static let shared: GodToolsParserLogger = GodToolsParserLogger()
    
    private var isStarted: Bool = false
    
    private init() {
        
    }
    
    func start() {
        
        guard !isStarted else {
            return
        }
        
        isStarted = true
                
        NapierProxyKt.enableCustomLogging { (logLevel: NapierLogLevel, tag: String?, throwable: KotlinThrowable?, message: String?) in
            
            DispatchQueue.global().async {
                
                Crashlytics.crashlytics().log("\(String(describing: tag)): \(String(describing: message))")
                if let error = throwable?.asError() {
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        }
    }
}
