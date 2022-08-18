//
//  Publisher+ReceiveOnMain.swift
//  godtools
//
//  Created by Rachael Skeath on 8/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

extension Publisher {
    
    public func receiveOnMain() -> AnyPublisher<Self.Output, Self.Failure> {
        
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
