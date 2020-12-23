//
//  RequestReceipt.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class RequestReceipt<T>: NSObject {
    
    private let queue: OperationQueue
    private let progress: ObservableValue<Double> = ObservableValue(value: 0)
    private let completed: SignalValue<T?> = SignalValue()
    
    required init(queue: OperationQueue) {
        self.queue = queue
        super.init()
    }
    
    func cancel() {
        queue.cancelAllOperations()
    }
    
    func addProgressObserver(observer: NSObject, onObserve: @escaping ObservableValue<Double>.Handler) {
        progress.addObserver(observer, onObserve: onObserve)
    }
    
    func updateProgress(progress: Double) {
        
        var progressValue: Double = progress
        if progressValue < 0 {
            progressValue = 0
        }
        else if progressValue > 1 {
            progressValue = 1
        }
        
        self.progress.accept(value: progressValue)
    }
    
    func complete(value: T?) {
        completed.accept(value: value)
    }
    
    func addCompletedObserver(observer: NSObject, onObserve: @escaping SignalValue<T?>.Handler) {
        completed.addObserver(observer, onObserve: onObserve)
    }
}
