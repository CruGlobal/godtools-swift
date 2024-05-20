//
//  DeleteAccountProgressInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct DeleteAccountProgressInterfaceStringsDomainModel {
    
    let title: String
    
    static func emptyStrings() -> DeleteAccountProgressInterfaceStringsDomainModel {
        return DeleteAccountProgressInterfaceStringsDomainModel(title: "")
    }
}
