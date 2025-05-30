//
//  GetUrlSessionPriorityInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/29/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol GetUrlSessionPriorityInterface {
    
    func getUrlSession(priority: SendRequestPriority) -> URLSession
}
