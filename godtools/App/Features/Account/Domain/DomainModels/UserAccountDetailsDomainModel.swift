//
//  UserAccountDetailsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserAccountDetailsDomainModel: Sendable {
    
    let name: String
    let joinedOnString: String
    
    static var emptyValue: UserAccountDetailsDomainModel {
        return UserAccountDetailsDomainModel(name: "", joinedOnString: "")
    }
}
