//
//  SearchBarStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct SearchBarStringsDomainModel: Sendable {
    
    let cancel: String
    
    static var emptyValue: SearchBarStringsDomainModel {
        return SearchBarStringsDomainModel(cancel: "")
    }
}
