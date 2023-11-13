//
//  GetToolScreenShareViewedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolScreenShareViewedRepository: GetToolScreenShareViewedRepositoryInterface {
    
    private let toolScreenShareViewsRepository: ToolScreenShareViewsRepository
    
    init(toolScreenShareViewsRepository: ToolScreenShareViewsRepository) {
        
        self.toolScreenShareViewsRepository = toolScreenShareViewsRepository
    }
    
    // TODO: Eventually ToolDomainModel should be passed here instead of ResourceModel. ~Levi
    func getViewed(tool: ResourceModel) -> AnyPublisher<ToolScreenShareViewedDomainModel, Never> {
        
        return toolScreenShareViewsRepository
            .getToolScreenShareViewPublisher(id: tool.id)
            .map { (toolScreenShare: ToolScreenShareViewDataModel?) in
                
                let numberOfViews: Int = toolScreenShare?.numberOfViews ?? 0
                
                return ToolScreenShareViewedDomainModel(numberOfViews: numberOfViews)
            }
            .eraseToAnyPublisher()
    }
}
