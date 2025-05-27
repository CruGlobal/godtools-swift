//
//  Temp.swift
//  godtools
//
//  Created by Levi Eggert on 4/29/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class TempPriorityRequestSender: PriorityRequestSenderInterface {
    
    static let shared: TempPriorityRequestSender = TempPriorityRequestSender()
    
    private init() {
        
    }
    
    func createRequestSender(sendRequestPriority: SendRequestPriority) -> RequestSender {
        
        switch sendRequestPriority {
            
        case .low:
            break
        case .medium:
            break
        case .high:
            break
        }
        
        return RequestSender()
    }
}
