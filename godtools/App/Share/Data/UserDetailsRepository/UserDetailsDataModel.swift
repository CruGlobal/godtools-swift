//
//  UserDetailsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserDetailsDataModel: UserDetailsDataModelType {
    
    let id: String
    let createdAt: Date?
    let familyName: String?
    let givenName: String?
    let name: String?
    let ssoGuid: String?
    
    init(userDetailsType: UserDetailsDataModelType) {
        
        id = userDetailsType.id
        createdAt = userDetailsType.createdAt
        familyName = userDetailsType.familyName
        givenName = userDetailsType.givenName
        name = userDetailsType.name
        ssoGuid = userDetailsType.ssoGuid
    }
}
