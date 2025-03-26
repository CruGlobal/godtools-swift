//
//  RealmObjectSubscription.swift
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
    
    class RealmObjectSubscription<T: Object, S: Subscriber>: NSObject, Subscription where S.Input == ObjectChange<RLMObjectBase>, S.Failure == Never {
        
        private let realmObject: T
        
        private var token: NotificationToken?
        private var subscriber: S?
        
        init(realmObject: T, subscriber: S) {
            
            self.realmObject = realmObject
            self.subscriber = subscriber
            
            super.init()
            
            token = realmObject.observe { change in
                
                _ = subscriber.receive(change)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            // Optionaly Adjust The Demand
        }
        
        func cancel() {
            token?.invalidate()
            token = nil
            subscriber = nil
        }
    }
}
