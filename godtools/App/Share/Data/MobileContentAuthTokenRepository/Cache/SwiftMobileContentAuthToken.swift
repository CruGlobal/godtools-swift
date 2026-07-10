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
    class SwiftMobileContentAuthToken: IdentifiableSwiftDataObject {
        
        var expirationDate: Date?
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var userId: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftMobileContentAuthToken {
    
    public static func idPredicate(id: String) -> Predicate<SwiftMobileContentAuthToken> {
        return #Predicate<SwiftMobileContentAuthToken> { object in
            object.id == id
        }
    }

    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftMobileContentAuthToken> {
        return #Predicate<SwiftMobileContentAuthToken> { object in
            ids.contains(object.id)
        }
    }
    
    func mapFrom(model: MobileContentAuthTokenDataModel) {
        
        expirationDate = model.expirationDate
        id = model.id
        userId = model.userId
    }
    
    static func createNewFrom(model: MobileContentAuthTokenDataModel) -> SwiftMobileContentAuthToken {
        let object = SwiftMobileContentAuthToken()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> MobileContentAuthTokenDataModel {
    
        return MobileContentAuthTokenDataModel(
            id: id,
            appleRefreshToken: nil,
            expirationDate: expirationDate,
            token: "",
            userId: userId
        )
    }
}
