//
//  IncrementNumberOfToolScreenShareTutorialViewsRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol IncrementNumberOfToolScreenShareTutorialViewsRepositoryInterface {
    
    func incrementNumberOfViewsForTool(toolId: String, incrementBy: Int) -> AnyPublisher<Void, Never>
}
