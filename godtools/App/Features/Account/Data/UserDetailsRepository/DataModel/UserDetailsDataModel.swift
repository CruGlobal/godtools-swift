//
//  UserDetailsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserDetailsDataModel {
    
    let id: String
    let createdAt: Date?
    let familyName: String?
    let givenName: String?
    let name: String?
    let ssoGuid: String?
    
    static func emptyDataModel() -> UserDetailsDataModel {
        return UserDetailsDataModel(id: "", createdAt: nil, familyName: nil, givenName: nil, name: nil, ssoGuid: nil)
    }
}
