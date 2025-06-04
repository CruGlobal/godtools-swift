//
//  Temp.swift
//  godtools
//
//  Created by Levi Eggert on 4/29/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class TempPriorityRequestSender: GetUrlSessionPriorityInterface {
    
    static let shared: TempPriorityRequestSender = TempPriorityRequestSender()
    
    private let urlSession: URLSession = URLSession(configuration: CreateIgnoreCacheSessionConfig().createConfig())
    
    private init() {
        
    }
    
    func getUrlSession(priority: SendRequestPriority) -> URLSession {
        
        switch priority {
            
        case .low:
            break
        case .medium:
            break
        case .high:
            break
        }
        
        return urlSession
    }
}
