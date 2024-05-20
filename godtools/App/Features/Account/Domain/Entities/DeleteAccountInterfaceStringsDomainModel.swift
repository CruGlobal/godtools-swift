//
//  DeleteAccountInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct DeleteAccountInterfaceStringsDomainModel {
    
    let title: String
    let subtitle: String
    let confirmActionTitle: String
    let cancelActionTitle: String
    
    static func emptyStrings() -> DeleteAccountInterfaceStringsDomainModel {
        return DeleteAccountInterfaceStringsDomainModel(title: "", subtitle: "", confirmActionTitle: "", cancelActionTitle: "")
    }
}
