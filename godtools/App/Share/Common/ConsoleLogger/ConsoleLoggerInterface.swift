//
//  ConsoleLoggerInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol ConsoleLoggerInterface: Sendable {
    
    func log(message: String)
}
