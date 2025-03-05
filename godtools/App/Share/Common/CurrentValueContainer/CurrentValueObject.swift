//
//  CurrentValueObject.swift
//  godtools
//
//  Created by Levi Eggert on 3/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class CurrentValueObject<Output, Failure> where Failure : Error {
    
    let id: CurrentValueContainer.Id
    let currentValueSubject: CurrentValueSubject<Output?, Failure>
    
    init(id: CurrentValueContainer.Id, currentValueSubject: CurrentValueSubject<Output?, Failure>) {
        
        self.id = id
        self.currentValueSubject = currentValueSubject
    }
    
    var value: Output? {
        return currentValueSubject.value
    }
    
    var publisher: AnyPublisher<Output?, Failure> {
        return currentValueSubject.eraseToAnyPublisher()
    }

    func setValue(value: Output?) {
        currentValueSubject.value = value
    }
    
    func removeValue() {
        currentValueSubject.value = nil
    }
    
    func sendValue(value: Output?) {
        currentValueSubject.send(value)
    }
    
    func sendCompletion(completion: Subscribers.Completion<Failure>) {
        currentValueSubject.send(completion: completion)
    }
}
