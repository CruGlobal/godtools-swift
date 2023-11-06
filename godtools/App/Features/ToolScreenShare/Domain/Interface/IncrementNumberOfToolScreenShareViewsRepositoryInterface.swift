//
//  IncrementNumberOfToolScreenShareViewsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol IncrementNumberOfToolScreenShareViewsRepositoryInterface {
    
    // TODO: Eventually ToolDomainModel should be passed here instead of ResourceModel. ~Levi
    func incrementNumberOfViewsForTool(tool: ResourceModel, incrementBy: Int) -> AnyPublisher<Void, Never>
}
