//
//  SetTimeout.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SetTimeout {
    
    static func setTimeout(seconds: TimeInterval, completion: @escaping (() -> Void)) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            completion()
        }
    }
    
    static func setTimeoutPublisher(seconds: TimeInterval) -> AnyPublisher<Void, Never> {
        
        return Future() { promise in
            
            SetTimeout.setTimeout(seconds: seconds) {
                
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
