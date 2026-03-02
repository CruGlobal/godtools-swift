//
//  ConfirmRemoveToolFromFavoritesStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct ConfirmRemoveToolFromFavoritesStringsDomainModel: Sendable {
    
    let title: String
    let message: String
    let confirmRemoveActionTitle: String
    let cancelRemoveActionTitle: String
    
    static var emptyValue: ConfirmRemoveToolFromFavoritesStringsDomainModel {
        return ConfirmRemoveToolFromFavoritesStringsDomainModel(title: "", message: "", confirmRemoveActionTitle: "", cancelRemoveActionTitle: "")
    }
}
