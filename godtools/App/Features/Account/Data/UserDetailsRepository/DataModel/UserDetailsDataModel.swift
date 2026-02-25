//
//  UserDetailsDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserDetailsDataModel: UserDetailsDataModelInterface {
    
    let id: String
    let createdAt: Date?
    let familyName: String?
    let givenName: String?
    let name: String?
    let ssoGuid: String?
    
    init(id: String, createdAt: Date?, familyName: String?, givenName: String?, name: String?, ssoGuid: String?) {
        
        self.id = id
        self.createdAt = createdAt
        self.familyName = familyName
        self.givenName = givenName
        self.name = name
        self.ssoGuid = ssoGuid
    }
    
    init(interface: UserDetailsDataModelInterface) {
        
        id = interface.id
        createdAt = interface.createdAt
        familyName = interface.familyName
        givenName = interface.givenName
        name = interface.name
        ssoGuid = interface.ssoGuid
    }
    
    static func emptyDataModel() -> UserDetailsDataModel {
        return UserDetailsDataModel(id: "", createdAt: nil, familyName: nil, givenName: nil, name: nil, ssoGuid: nil)
    }
}
