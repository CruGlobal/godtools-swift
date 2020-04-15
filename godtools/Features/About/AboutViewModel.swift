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
    
    let navTitle: ObservableValue<String> = ObservableValue(value: NSLocalizedString("about", comment: ""))
    
    required init(analytics: GodToolsAnaltyics) {
        
        self.analytics = analytics        
    }
    
    func pageViewed() {
        analytics.recordScreenView(screenName: "About", siteSection: "menu", siteSubSection: "")
    }
}
