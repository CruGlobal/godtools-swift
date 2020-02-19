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
    
    required init(globalActivityAttribute: GlobalActivityAttribute, isLoading: Bool) {
        
        count = isLoading ? "" : String(globalActivityAttribute.count)
        
        let localizedTitle: String
        switch globalActivityAttribute.activityType {
        case .users:
            localizedTitle = NSLocalizedString("accountActivity.globalAnalytics.users.title", comment: "")
        case .countries:
            localizedTitle = NSLocalizedString("accountActivity.globalAnalytics.countries.title", comment: "")
        case .launches:
            localizedTitle = NSLocalizedString("accountActivity.globalAnalytics.launches.title", comment: "")
        case .gospelPresentation:
            localizedTitle = NSLocalizedString("accountActivity.globalAnalytics.gospelPresentation.title", comment: "")
        }
        
        if isLoading {
            title = NSLocalizedString("accountActivity.globalAnalytics.loading.prefix", comment: "") + " " + localizedTitle
        }
        else {
            title = localizedTitle
        }
        
        self.isLoading = isLoading
    }
}
