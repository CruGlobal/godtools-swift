//
//  Publisher+ReceiveOnMain.swift
//  SharedAppleExtensions
//
//  Created by Rachael Skeath on 8/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

public extension Publisher {
    
    func receiveOnMain() -> AnyPublisher<Self.Output, Self.Failure> {
        
        return self.propagateErrorOnMainIfNeeded()
            .receiveOnMainIfNeeded()
    }
    
    private func propagateErrorOnMainIfNeeded() -> AnyPublisher<Self.Output, Self.Failure> {
        
        return self.catch { error in
            
            let dummyValue = false
            
            return Just(dummyValue)
                .receiveOnMainIfNeeded()
                .flatMap { _ -> AnyPublisher<Self.Output, Self.Failure> in
                    
                    return Fail<Self.Output, Self.Failure>(error: error)
                        .eraseToAnyPublisher()
                }
        }
            .eraseToAnyPublisher()
    }
    
    private func receiveOnMainIfNeeded() -> AnyPublisher<Self.Output, Self.Failure> {
        
        return self.flatMap({ value -> AnyPublisher<Self.Output, Self.Failure> in
            
            if Thread.isMainThread {
                
                return Just(value)
                    .setFailureType(to: Self.Failure.self)
                    .eraseToAnyPublisher()
                
            } else {
                
                return Just(value)
                    .setFailureType(to: Self.Failure.self)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
                
            }
            
        }).eraseToAnyPublisher()
    }
}
