//
//  DeleteAccountProgressStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct DeleteAccountProgressStringsDomainModel: Sendable {
    
    let title: String
    
    static var emptyValue: DeleteAccountProgressStringsDomainModel {
        return DeleteAccountProgressStringsDomainModel(title: "")
    }
}
