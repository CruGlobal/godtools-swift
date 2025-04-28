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
