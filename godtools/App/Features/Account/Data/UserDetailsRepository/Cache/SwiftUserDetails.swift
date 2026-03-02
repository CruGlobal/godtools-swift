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
    class SwiftUserDetails: IdentifiableSwiftDataObject, UserDetailsDataModelInterface {
        
        var createdAt: Date?
        var familyName: String?
        var givenName: String?
        var name: String?
        var ssoGuid: String?
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
        
        func mapFrom(interface: UserDetailsDataModelInterface) {
            
            id = interface.id
            createdAt = interface.createdAt
            familyName = interface.familyName
            givenName = interface.givenName
            name = interface.name
            ssoGuid = interface.ssoGuid
        }
        
        static func createNewFrom(interface: UserDetailsDataModelInterface) -> SwiftUserDetails {
            let object = SwiftUserDetails()
            object.mapFrom(interface: interface)
            return object
        }
    }
}
