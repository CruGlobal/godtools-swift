//
//  GetToolScreenShareViewedRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolScreenShareViewedRepositoryInterface {
    
    // TODO: Eventually ToolDomainModel should be passed here instead of ResourceModel. ~Levi
    func getViewed(tool: ResourceModel) -> AnyPublisher<ToolScreenShareViewedDomainModel, Never>
}
