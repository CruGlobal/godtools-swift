//
//  GlobalActivityHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class GlobalActivityHeaderViewModel {
    
    let headerTitle: String
    
    required init() {
        
        let todaysDate: Date = Date()
        let components: DateComponents = Calendar.current.dateComponents([.year], from: todaysDate)
        let currentYear: String
        if let yearComponent = components.year {
            currentYear = String(yearComponent)
        }
        else {
            currentYear = ""
        }
        
        headerTitle = currentYear + " " + NSLocalizedString("accountActivity.globalAnalytics.header.title", comment: "")
    }
}
