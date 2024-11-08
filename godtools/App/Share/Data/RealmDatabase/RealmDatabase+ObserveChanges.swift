//
//  RealmDatabase+ObserveChanges.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

extension RealmDatabase {
    
    func observeCollectionChangesPublisher(objectClass: Object.Type, prepend: Bool) -> AnyPublisher<Void, Never> {
        
        if prepend {
           
            return openRealm()
                .objects(objectClass.self)
                .objectWillChange
                .prepend(Void())
                .eraseToAnyPublisher()
        }
        else {
            
            return openRealm()
                .objects(objectClass.self)
                .objectWillChange
                .eraseToAnyPublisher()
        }
    }
}
