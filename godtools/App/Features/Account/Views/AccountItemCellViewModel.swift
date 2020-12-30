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
    
    required init(item: AccountItem, localizationServices: LocalizationServices, globalActivityServices: GlobalActivityServices) {
        
        switch item.itemId {
        case .activity:
            let viewModel = AccountActivityViewModel(
                localizationServices: localizationServices,
                globalActivityServices: globalActivityServices
            )
            itemView = AccountActivityView(viewModel: viewModel)
        }
    }
}
