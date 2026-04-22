//
//  SwiftEmailSignUp.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftEmailSignUp = SwiftEmailSignUpV1.SwiftEmailSignUp

@available(iOS 17.4, *)
enum SwiftEmailSignUpV1 {
 
    @Model
    class SwiftEmailSignUp: IdentifiableSwiftDataObject {
        
        var firstName: String?
        var isRegistered: Bool = false
        var lastName: String?
        
        @Attribute(.unique) var email: String = ""
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftEmailSignUp {
    
    func mapFrom(model: EmailSignUpDataModel) {
        
        id = model.id
        email = model.email
        firstName = model.firstName
        lastName = model.lastName
        isRegistered = model.isRegistered
    }
    
    static func createNewFrom(model: EmailSignUpDataModel) -> SwiftEmailSignUp {
        let object = SwiftEmailSignUp()
        object.mapFrom(model: model)
        return object
    }
}

@available(iOS 17.4, *)
extension SwiftEmailSignUp {
    
    func toModel() -> EmailSignUpDataModel {
        return EmailSignUpDataModel(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            isRegistered: isRegistered
        )
    }
}
