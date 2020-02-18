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
    
    required init(globalActivityAttribute: GlobalActivityAttribute) {
        
        count = String(globalActivityAttribute.count)
        
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
    }
}
