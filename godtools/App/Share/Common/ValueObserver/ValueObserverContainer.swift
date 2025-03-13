//
//  ValueObserverContainer.swift
//  godtools
//
//  Created by Levi Eggert on 3/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ValueObserverContainer<T> {
    
    typealias Id = String
    
    private let defaultValue: T
    
    private var valueObservers: [Id: ValueObserver<T>] = Dictionary()
    
    init(defaultValue: T) {
        
        self.defaultValue = defaultValue
    }
    
    func observer(id: Id) -> ValueObserver<T> {
                
        if let existing = valueObservers[id] {
            return existing
        }
        
        let new: ValueObserver<T> = ValueObserver(value: defaultValue)
        valueObservers[id] = new
        
        return new
    }
    
    func removeObserver(id: Id) {
        valueObservers[id] = nil
    }
    
    func removeAllObservers() {
        valueObservers.removeAll()
    }
}
