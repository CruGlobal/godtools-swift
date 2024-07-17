//
//  TrackShareShareableTapUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class TrackShareShareableTapUseCase {
    
    private let trackTap: TrackShareShareableTapInterface
    
    init(trackTap: TrackShareShareableTapInterface) {
        
        self.trackTap = trackTap
    }
    
    func trackPublisher(toolId: String, shareableId: String) -> AnyPublisher<Void, Never> {
        
        return trackTap
            .trackShareShareableTapPublisher(toolId: toolId, shareableId: shareableId)
            .eraseToAnyPublisher()
    }
}
