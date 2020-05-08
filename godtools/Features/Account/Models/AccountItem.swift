//
//  AccountItem.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct AccountItem: GTSegmentType {
    let itemId: AccountItemId
    let title: String
    let analyticsScreenName: String
}

extension AccountItem {
    var id: String {
        return itemId.rawValue
    }
}
