//
//  ObservableValue.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ObservableValue<T> {
    
    typealias Handler = ((_ value: T) -> Void)
    
    private(set) var value : T

    private var observers = [String: Handler]()

    deinit {
        observers.removeAll()
    }
    
    init(value: T) {
        self.value = value
    }
    
    func accept(value: T) {
        self.value = value
        notifyAllObservers()
    }
    
    func setValue(value: T) {
        self.value = value
    }

    func addObserver(_ observer: NSObject, onObserve: @escaping Handler) {
        observers[observer.description] = onObserve
        onObserve(value)
    }
    
    func removeObserver(_ observer: NSObject) {
        observers[observer.description] = nil
    }
    
    func removeAllObservers() {
        observers.removeAll()
    }

    private func notifyAllObservers() {
        observers.forEach({ $0.value(value) })
    }
}
