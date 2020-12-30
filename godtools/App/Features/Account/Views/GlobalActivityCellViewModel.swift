//
//  GlobalActivityCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class GlobalActivityCellViewModel {
    
    let count: String
    let title: String
    let isLoading: Bool
    
    required init(globalActivityAttribute: GlobalActivityAttribute, localizationServices: LocalizationServices, isLoading: Bool, errorOccurred: Bool) {
        
        if isLoading && globalActivityAttribute.count == 0 {
            count = "-"
        }
        else if errorOccurred {
            count = "-"
        }
        else {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            count = numberFormatter.string(from: NSNumber(value: globalActivityAttribute.count)) ?? String(globalActivityAttribute.count)
        }
        
        switch globalActivityAttribute.activityType {
        case .users:
            title = localizationServices.stringForMainBundle(key: "accountActivity.globalAnalytics.users.title")
        case .countries:
            title = localizationServices.stringForMainBundle(key: "accountActivity.globalAnalytics.countries.title")
        case .launches:
            title = localizationServices.stringForMainBundle(key: "accountActivity.globalAnalytics.launches.title")
        case .gospelPresentation:
            title = localizationServices.stringForMainBundle(key: "accountActivity.globalAnalytics.gospelPresentation.title")
        }
        
        self.isLoading = isLoading
    }
}
