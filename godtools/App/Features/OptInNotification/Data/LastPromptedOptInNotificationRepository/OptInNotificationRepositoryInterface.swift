//
//  OptInNotificationRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/17/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol OptInNotificationRepositoryInterface {
    
    func getLastPrompted() -> Date?
    func getPromptCount() -> Int
    func recordPrompt()
}
