//
//  AccountViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AccountViewModel: AccountViewModelType {
    
    let navTitle: String
    let items: [AccountItem]
    
    required init() {
        
        navTitle = NSLocalizedString("account.navTitle", comment: "")
        items = [AccountItem(itemId: .activity, title: "Activity", itemViewNibName: "")]
    }
}
