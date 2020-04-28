//
//  FindToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FindToolsViewModel: FindToolsViewModelType {
    
    private let analytics: GodToolsAnaltyics
    
    required init(analytics: GodToolsAnaltyics) {
        
        self.analytics = analytics
    }
    
    func pageViewed() {
        
        analytics.recordScreenView(screenName: "Find Tools", siteSection: "tools", siteSubSection: "")
    }
}
