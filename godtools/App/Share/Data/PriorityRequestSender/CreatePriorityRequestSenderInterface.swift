//
//  CreatePriorityRequestSenderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/29/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol CreatePriorityRequestSenderInterface {
    
    func createRequestSender(sendRequestPriority: SendRequestPriority) -> RequestSender
}
