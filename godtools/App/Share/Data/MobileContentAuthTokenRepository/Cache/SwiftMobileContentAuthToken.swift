//
//  SwiftMobileContentAuthToken.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftMobileContentAuthToken = SwiftMobileContentAuthTokenV1.SwiftMobileContentAuthToken

@available(iOS 17.4, *)
enum SwiftMobileContentAuthTokenV1 {
 
    @Model
    class SwiftMobileContentAuthToken: IdentifiableSwiftDataObject, MobileContentAuthTokenDataModelInterface {
        
        var expirationDate: Date?
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var userId: String = ""
        
        init() {
            
        }
        
        func mapFrom(interface: MobileContentAuthTokenDataModelInterface) {
            
            expirationDate = interface.expirationDate
            id = interface.id
            userId = interface.userId
        }
        
        static func createNewFrom(interface: MobileContentAuthTokenDataModelInterface) -> SwiftMobileContentAuthToken {
            let object = SwiftMobileContentAuthToken()
            object.mapFrom(interface: interface)
            return object
        }
    }
}
