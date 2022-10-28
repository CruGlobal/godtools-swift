//
//  AccountItemCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AccountItemCellViewModel {
    
    let itemView: AccountItemViewType
    
    required init(item: AccountItem, localizationServices: LocalizationServices, globalAnalyticsService: GlobalAnalyticsService) {
        
        switch item.itemId {
        case .activity:
            let viewModel = AccountActivityViewModel(
                localizationServices: localizationServices,
                globalAnalyticsService: globalAnalyticsService
            )
            itemView = AccountActivityView(viewModel: viewModel)
        }
    }
}
