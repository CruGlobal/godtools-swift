//
//  HashableCurrentValueSubject.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class HashableCurrentValueSubject<HashType: Hashable, ValueType, FailureType: Error> {
    
    private var currentValueSubjectDictionary: [HashType: CurrentValueSubject<ValueType?, FailureType>] = Dictionary()
    
    init() {
        
    }
    
    private func getCurrentValueSubject(hash: HashType) -> CurrentValueSubject<ValueType?, FailureType> {
        
        guard let currentValueSubject = currentValueSubjectDictionary[hash] else {
            
            let newSubject: CurrentValueSubject<ValueType?, FailureType> = CurrentValueSubject(nil)
            
            currentValueSubjectDictionary[hash] = newSubject
            
            return newSubject
        }
        
        return currentValueSubject
    }
    
    func getValueChangedPublisher(hash: HashType) -> AnyPublisher<ValueType?, FailureType> {
        
        return getCurrentValueSubject(hash: hash)
            .eraseToAnyPublisher()
    }
    
    func storeValue(hash: HashType, value: ValueType?) {
        
        getCurrentValueSubject(hash: hash).send(value)
    }
}
