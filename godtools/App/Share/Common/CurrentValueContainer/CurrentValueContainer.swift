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
    
    private var currentValueSubjects: [String: CurrentValueSubject<Output?, Failure>] = Dictionary()
    
    func getCurrentValueSubject(id: String) -> CurrentValueSubject<Output?, Failure> {
                
        if let existing = currentValueSubjects[id] {
            return existing
        }
        
        let new = CurrentValueSubject<Output?, Failure>(nil)
        currentValueSubjects[id] = new
        
        return new
    }
    
    func getPublisher(id: String) -> AnyPublisher<Output?, Failure> {
        return getCurrentValueSubject(id: id).eraseToAnyPublisher()
    }
    
    func getValue(id: String) -> Output? {
        return getCurrentValueSubject(id: id).value
    }
    
    func setValue(id: String, value: Output?) {
        getCurrentValueSubject(id: id).value = value
    }
    
    func removeValue(id: String) {
        getCurrentValueSubject(id: id).value = nil
    }
    
    func sendValue(id: String, value: Output?) {
        getCurrentValueSubject(id: id).send(value)
    }
    
    func sendCompletion(id: String, completion: Subscribers.Completion<Failure>) {
        getCurrentValueSubject(id: id).send(completion: completion)
    }
    
    func remove(id: String) {
        currentValueSubjects[id] = nil
    }
    
    func removeAll() {
        currentValueSubjects.removeAll()
    }
}
