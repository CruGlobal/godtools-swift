//
//  AccountItemCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AccountItemCellViewModel {
    
    let itemView: UIView
    
    required init(item: AccountItem) {
        
        itemView = AccountActivityView()
    }
}
