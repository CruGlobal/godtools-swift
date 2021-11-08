//
//  PassthroughValue.swift
//  godtools
//
//  Created by Levi Eggert on 10/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class PassthroughValue<T> {
    
    typealias Handler = ((_ value: T) -> Void)
    
    private var observers: [String: Handler] = Dictionary()
        
    required init() {

    }
    
    deinit {
        observers.removeAll()
    }
    
    var numberOfObservers: Int {
        return observers.count
    }
    
    func accept(value: T) {
        notifyAllObservers(value: value)
    }
    
    func addObserver(_ observer: NSObject, onObserve: @escaping Handler) {
        observers[observer.description] = onObserve
    }
    
    func removeObserver(_ observer: NSObject) {
        observers[observer.description] = nil
    }
    
    func removeAllObservers() {
        observers.removeAll()
    }
    
    private func notifyAllObservers(value: T) {
        for (_, onObserve) in observers {
            onObserve(value)
        }
    }
}
