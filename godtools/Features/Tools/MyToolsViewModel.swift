//
//  MyToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MyToolsViewModel: MyToolsViewModelType {
    
    private let analytics: GodToolsAnaltyics
    
    required init(analytics: GodToolsAnaltyics) {
        
        self.analytics = analytics
    }
    
    func pageViewed() {
        
        analytics.recordScreenView(screenName: "Home", siteSection: "", siteSubSection: "")
    }
}
