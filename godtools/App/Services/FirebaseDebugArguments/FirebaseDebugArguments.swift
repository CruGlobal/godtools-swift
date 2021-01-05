//
//  FirebaseDebugArguments.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FirebaseDebugArguments {
    
    private let enableFirebaseDebugArguments: [String]
    private let disableFirebaseDebugArguments: [String]
            
    required init() {
        
        self.enableFirebaseDebugArguments = ["-FIRDebugEnabled", "-FIRAnalyticsDebugEnabled"]
        self.disableFirebaseDebugArguments = ["-FIRDebugDisabled", "-FIRAnalyticsDebugDisabled"]
    }
    
    func enable() {
               
        ProcessInfo.processInfo.setValue(
            addArguments(arguments: enableFirebaseDebugArguments, toArguments: ProcessInfo.processInfo.arguments),
            forKey: "arguments"
        )
    }
    
    private func addArguments(arguments: [String], toArguments: [String]) -> [String] {
        
        var newArguments: [String] = toArguments
        
        for argument in arguments {
            if !newArguments.contains(argument) {
                newArguments.append(argument)
            }
        }
        
        return newArguments
    }
}
