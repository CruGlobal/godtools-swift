//
//  ViewedTrainingTipsCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 12/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ViewedTrainingTipsCacheType {
    
    func containsViewedTrainingTip(viewedTrainingTip: ViewedTrainingTipType) -> Bool
    func storeViewedTrainingTip(viewedTrainingTip: ViewedTrainingTipType)
}
