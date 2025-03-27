//
//  RealmObjectPublisher.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/25.
//  Copyright © 2025 Cru Global, Inc. All rights reserved.
//

import Foundation
import Combine
import Realm
import RealmSwift

extension Publishers {
    
    struct RealmObjectPublisher<T: Object>: Publisher {
        
        typealias Output = ObjectChange<RLMObjectBase>
        typealias Failure = Never
        
        private let realmObject: T
        
        init(realmObject: T) {
            
            self.realmObject = realmObject
        }
        
        func receive<S: Subscriber>(subscriber: S) where RealmObjectPublisher.Failure == S.Failure, RealmObjectPublisher.Output == S.Input {
                
            let subscription = RealmObjectSubscription(realmObject: realmObject, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}
