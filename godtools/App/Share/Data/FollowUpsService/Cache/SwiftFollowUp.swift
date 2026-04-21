//
//  SwiftFollowUp.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftFollowUp = SwiftFollowUpV1.SwiftFollowUp

@available(iOS 17.4, *)
enum SwiftFollowUpV1 {
 
    @Model
    class SwiftFollowUp: IdentifiableSwiftDataObject {
        
        var email: String = ""
        var destinationId: Int = -1
        var languageId: Int = -1
        var name: String = ""
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftFollowUp {
    
    func mapFrom(model: FollowUpDataModel) {
        
        id = model.id
        name = model.name
        email = model.email
        destinationId = model.destinationId
        languageId = model.languageId
    }
    
    static func createNewFrom(model: FollowUpDataModel) -> SwiftFollowUp {
        let object = SwiftFollowUp()
        object.mapFrom(model: model)
        return object
    }
}

@available(iOS 17.4, *)
extension SwiftFollowUp {
    func toModel() -> FollowUpDataModel {
        return FollowUpDataModel(
            id: id,
            name: name,
            email: email,
            destinationId: destinationId,
            languageId: languageId
        )
    }
}
