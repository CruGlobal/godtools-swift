//
//  GodToolsParserLogger.swift
//  godtools
//
//  Created by Levi Eggert on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import FirebaseCrashlytics

class GodToolsParserLogger {
    
    private var errorReporting: ErrorReportingInterface?
    private var firebaseErrorReporting: FirebaseNonFatalErrorReporting?
    
    static let shared: GodToolsParserLogger = GodToolsParserLogger()
    
    private var isStarted: Bool = false
    
    private init() {
        
    }
    
    func start(errorReporting: ErrorReportingInterface, firebaseErrorReporting: FirebaseNonFatalErrorReporting) {
        
        self.errorReporting = errorReporting
        self.firebaseErrorReporting = firebaseErrorReporting
        
        guard !isStarted else {
            return
        }
        
        isStarted = true
                
        LoggingKt.enableCustomLogging { [weak self] (logLevel: LogLevel, tag: String?, throwable: KotlinThrowable?, message: String?) in

            DispatchQueue.global().async { [weak self] in

                if let tag = tag, let message = message {
                    self?.firebaseErrorReporting?.log(tag: tag, message: message)
                }

                if let error = throwable?.asError() {
                    self?.errorReporting?.reportError(error: error)
                }
            }
        }
    }
}
