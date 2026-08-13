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

actor GodToolsParserLogger: Sendable {
    
    private let errorReporting: ErrorReportingInterface
    private let firebaseErrorReporting: FirebaseNonFatalErrorReporting
    
    private var isStarted: Bool = false
            
    init(errorReporting: ErrorReportingInterface, firebaseErrorReporting: FirebaseNonFatalErrorReporting) {
        
        self.errorReporting = errorReporting
        self.firebaseErrorReporting = firebaseErrorReporting
    }
    
    func start() {
        
        guard !isStarted else {
            return
        }
        
        isStarted = true
                
        LoggingKt.enableCustomLogging { [weak self] (logLevel: LogLevel, tag: String?, throwable: KotlinThrowable?, message: String?) in

            let error: Error? = throwable?.asError()
            
            DispatchQueue.global().async { [weak self] in

                if let tag = tag, let message = message {
                    self?.firebaseErrorReporting.log(tag: tag, message: message)
                }

                if let error = error {
                    self?.errorReporting.reportError(error: error)
                }
            }
        }
    }
}
