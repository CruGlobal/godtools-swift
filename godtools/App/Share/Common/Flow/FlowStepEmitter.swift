//
//  FlowStepEmitter.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

public final class FlowStepEmitter {
    
    private let emitterSubject = PassthroughSubject<FlowStep, Never>()
    
    public init() {
        
    }
    
    public var publisher: AnyPublisher<FlowStep, Never> {
        return emitterSubject.eraseToAnyPublisher()
    }
    
    public func emit(step: FlowStep) {
        emitterSubject.send(step)
    }
}
