//
//  CreateUrlSessionConfigInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol CreateUrlSessionConfigInterface {
    
    func createConfiguration(timeoutIntervalForRequest: TimeInterval) -> URLSessionConfiguration
}
