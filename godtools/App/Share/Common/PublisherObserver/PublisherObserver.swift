//
//  PublisherObserver.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class PublisherObserver<Output, Failure> where Failure : Error {
    
    private var publisher: AnyPublisher<Output, Failure>?
    private var onReceive: ((_ value: Output) -> Void)?
    private var onCompletion: ((_ completion: Subscribers.Completion<Failure>) -> Void)?
    private var cancellable: AnyCancellable?
        
    private(set) var currentValue: Output?
    private(set) var completion: Subscribers.Completion<Failure>?
        
    init() {
        
    }
    
    var isRunning: Bool {
        return cancellable != nil
    }
    
    func cancel() {
                
        cancellable?.cancel()
        cancellable = nil
        onReceive = nil
        currentValue = nil
        onCompletion = nil
        completion = nil
        publisher = nil
    }
    
    func observe(onReceive: ((_ value: Output) -> Void)?, onCompletion: ((_ completion: Subscribers.Completion<Failure>) -> Void)?) {
        
        self.onReceive = onReceive
        self.onCompletion = onCompletion
    }

    func start(publisher: AnyPublisher<Output, Failure>) {
                         
        guard self.publisher == nil else {
            return
        }
        
        self.publisher = publisher
        
        cancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                
                self?.completion = completion
                                
                self?.onCompletion?(completion)
                
            } receiveValue: { [weak self] output in
                
                self?.currentValue = output
                                
                self?.onReceive?(output)
            }
    }
}
