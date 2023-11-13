//
//  GetToolScreenShareTutorialHasBeenViewedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolScreenShareTutorialHasBeenViewedUseCase {
    
    private let getToolScreenShareViewedRepositoryInterface: GetToolScreenShareViewedRepositoryInterface
    
    init(getToolScreenShareViewedRepositoryInterface: GetToolScreenShareViewedRepositoryInterface) {
        
        self.getToolScreenShareViewedRepositoryInterface = getToolScreenShareViewedRepositoryInterface
    }
    
    // TODO: Eventually ToolDomainModel should be passed in here instead of ResourceModel. ~Levi
    func getViewedPublisher(tool: ResourceModel) -> AnyPublisher<ToolScreenShareViewedDomainModel, Never> {
        
        return getToolScreenShareViewedRepositoryInterface.getViewed(tool: tool)
            .eraseToAnyPublisher()
    }
}
