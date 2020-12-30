//
//  Signal.swift
//  godtools
//
//  Created by Levi Eggert on 2/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class Signal {
    
    typealias Handler = (() -> Void)
    
    private var observers: [String: Handler] = Dictionary()
        
    required init() {

    }
    
    deinit {
        observers.removeAll()
    }
    
    func accept() {
        notifyAllObservers()
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
    
    private func notifyAllObservers() {
        for (_, onObserve) in observers {
            onObserve()
        }
    }
}
