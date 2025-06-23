//
//  FirebaseMessaging.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import FirebaseMessaging
import Combine

class FirebaseMessaging {
    
    init() {
        
    }
    
    func getDeviceToken(completion: @escaping ((_ result: Result<String, Error>) -> Void)) {

        Messaging.messaging().token { (token: String?, error: Error?) in
            
            if let error = error {
                completion(.failure(error))
            }
            else if let validToken = token, !validToken.isEmpty {
                completion(.success(validToken))
            }
            else {
                let error: Error = NSError.errorWithDescription(description: "Firebase device token is empty.")
                completion(.failure(error))
            }
        }
    }
    
    func getDeviceTokenPublisher() -> AnyPublisher<String, Error> {
        
        return Future() { promise in
            
            self.getDeviceToken { (result: Result<String, Error>) in
                
                switch result {
                case .success(let token):
                    promise(.success(token))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Needed since method swizzling is disabled in Info.plist for SwiftUI App Life Cycle.
// FirebaseAppDelegateProxyEnabled: NO

extension FirebaseMessaging {
    
    static func registerDeviceToken(deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    static func didReceiveMessage(userInfo: [AnyHashable: Any]) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
}
