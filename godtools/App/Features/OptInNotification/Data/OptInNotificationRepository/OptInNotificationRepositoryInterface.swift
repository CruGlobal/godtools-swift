//
//  OptInNotificationRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/17/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol OptInNotificationRepositoryInterface: Sendable {
    
    func getRemoteFeatureEnabled() async -> Bool
    func getRemoteTimeInterval() async -> Date
    func getRemotePromptLimit() async -> Int
    func getLastPrompted() async -> Date?
    func getPromptCount() async -> Int
    func recordPrompt() async
}
