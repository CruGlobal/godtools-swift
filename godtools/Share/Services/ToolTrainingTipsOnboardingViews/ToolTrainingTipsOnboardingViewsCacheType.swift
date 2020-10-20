//
//  ToolTrainingTipsOnboardingViewsCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolTrainingTipsOnboardingViewsCacheType {
    
    func getNumberOfToolTrainingTipViews(resource: ResourceModel) -> Int
    func storeToolTrainingTipViewed(resource: ResourceModel)
}
