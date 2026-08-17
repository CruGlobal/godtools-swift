//
//  ConsoleLogger.swift
//  godtools
//
//  Created by Levi Eggert on 8/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ConsoleLogger: ConsoleLoggerInterface {
    
    private let enabled: Bool
    
    init(enabled: Bool) {
        self.enabled = enabled
    }
    
    func log(message: String) {
     
        guard enabled else {
            return
        }
        
        print("\n LOGGER\n\n  class: \(type(of: self))\n  message: \(message)")
    }
}
