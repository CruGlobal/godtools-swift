//
//  ViewedTrainingTipsCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 12/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated)
protocol ViewedTrainingTipsCacheType {
    
    func containsViewedTrainingTip(id: String) -> Bool
}
