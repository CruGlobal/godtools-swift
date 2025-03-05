//
//  CurrentValueContainer.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class CurrentValueContainer<Output, Failure> where Failure : Error {
    
    typealias Id = String
    
    private var registeredObjects: [Id: CurrentValueObject<Output, Failure>] = Dictionary()
    
    func registerObject(id: Id) -> CurrentValueObject<Output, Failure> {
                
        if let existing = registeredObjects[id] {
            return existing
        }
        
        let new = CurrentValueObject<Output, Failure>(id: id, currentValueSubject: CurrentValueSubject(nil))
        registeredObjects[id] = new
        
        return new
    }
    
    func object(id: Id) -> CurrentValueObject<Output, Failure>? {
        
        guard let object = registeredObjects[id] else {
            return nil
        }
        
        return object
    }
    
    func unregisterObject(id: Id) {
        registeredObjects[id] = nil
    }
    
    func unregisterAllObjects() {
        registeredObjects.removeAll()
    }
}
