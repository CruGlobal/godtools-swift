//
//  TractViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractViewModel: TractViewModelType {
    
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    
    required init(appsFlyer: AppsFlyerType) {
        
        self.toolOpenedAnalytics = ToolOpenedAnalytics(appsFlyer: appsFlyer)
    }
    
    func viewLoaded() {
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded()
        toolOpenedAnalytics.trackToolOpened()
    }
}
