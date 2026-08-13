//
//  FirebaseMessaging.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import FirebaseMessaging

final class FirebaseMessaging: Sendable {
    
    static let shared: FirebaseMessaging = FirebaseMessaging()
    
    private init() {
        
    }
    
    func getDeviceToken() async throws -> String {
        
        return try await Messaging.messaging().token()
    }
}

// MARK: - Needed since method swizzling is disabled in Info.plist for SwiftUI App Life Cycle.
// FirebaseAppDelegateProxyEnabled: NO

extension FirebaseMessaging {
    
    func registerDeviceToken(deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func didReceiveMessage(userInfo: [AnyHashable: Any]) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
}
