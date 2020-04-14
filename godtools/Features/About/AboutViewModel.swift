//
//  AboutViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AboutViewModel: AboutViewModelType {
    
    private let analytics: GodToolsAnaltyics
    
    let navTitle: String
    
    required init(analytics: GodToolsAnaltyics) {
        
        self.analytics = analytics
        
        navTitle = NSLocalizedString("about", comment: "")
    }
    
    func pageViewed() {
        analytics.recordScreenView(screenName: "About", siteSection: "menu", siteSubSection: "")
    }
}
