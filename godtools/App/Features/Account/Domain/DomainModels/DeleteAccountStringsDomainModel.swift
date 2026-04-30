//
//  DeleteAccountStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct DeleteAccountStringsDomainModel: Sendable {
    
    let title: String
    let subtitle: String
    let confirmActionTitle: String
    let cancelActionTitle: String
    
    static var emptyValue: DeleteAccountStringsDomainModel {
        return DeleteAccountStringsDomainModel(title: "", subtitle: "", confirmActionTitle: "", cancelActionTitle: "")
    }
}
