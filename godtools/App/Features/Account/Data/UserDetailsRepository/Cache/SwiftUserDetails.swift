//
//  SwiftUserDetails.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserDetails = SwiftUserDetailsV1.SwiftUserDetails

@available(iOS 17.4, *)
enum SwiftUserDetailsV1 {
    
    @Model
    class SwiftUserDetails: IdentifiableSwiftDataObject {
        
        var createdAt: Date?
        var familyName: String?
        var givenName: String?
        var name: String?
        var ssoGuid: String?
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftUserDetails {
    
    func mapFrom(model: UserDetailsDataModel) {
        
        id = model.id
        createdAt = model.createdAt
        familyName = model.familyName
        givenName = model.givenName
        name = model.name
        ssoGuid = model.ssoGuid
    }
    
    static func createNewFrom(model: UserDetailsDataModel) -> SwiftUserDetails {
        let object = SwiftUserDetails()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> UserDetailsDataModel {
        return UserDetailsDataModel(
            id: id,
            createdAt: createdAt,
            familyName: familyName,
            givenName: givenName,
            name: name,
            ssoGuid: ssoGuid
        )
    }
}
