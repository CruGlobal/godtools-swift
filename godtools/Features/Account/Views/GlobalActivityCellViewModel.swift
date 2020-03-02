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
    
    required init(globalActivityAttribute: GlobalActivityAttribute, isLoading: Bool, errorOccurred: Bool) {
        
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
            title = NSLocalizedString("accountActivity.globalAnalytics.users.title", comment: "")
        case .countries:
            title = NSLocalizedString("accountActivity.globalAnalytics.countries.title", comment: "")
        case .launches:
            title = NSLocalizedString("accountActivity.globalAnalytics.launches.title", comment: "")
        case .gospelPresentation:
            title = NSLocalizedString("accountActivity.globalAnalytics.gospelPresentation.title", comment: "")
        }
        
        self.isLoading = isLoading
    }
}
