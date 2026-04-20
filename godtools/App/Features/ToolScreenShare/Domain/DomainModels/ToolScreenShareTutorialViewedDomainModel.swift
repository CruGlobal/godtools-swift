//
//  ToolScreenShareTutorialViewedDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolScreenShareTutorialViewedDomainModel: Sendable {
    
    let hasBeenViewed: Bool
    
    init(numberOfViews: Int) {
        
        hasBeenViewed = numberOfViews >= 3
    }
}
