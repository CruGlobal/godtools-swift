//
//  SwiftUserToolLanguageFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 10/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserToolLanguageFilter = SwiftUserToolLanguageFilterV1.SwiftUserToolLanguageFilter

@available(iOS 17.4, *)
enum SwiftUserToolLanguageFilterV1 {
    
    @Model
    class SwiftUserToolLanguageFilter: IdentifiableSwiftDataObject {
                
        var createdAt: Date = Date()
        var languageId: String = ""
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var filterId: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftUserToolLanguageFilter {
    
    func mapFrom(model: UserToolLanguageFilterDataModel) {
        
        id = model.id
        filterId = model.filterId
        languageId = model.languageId
        createdAt = model.createdAt
    }
    
    static func createNewFrom(model: UserToolLanguageFilterDataModel) -> SwiftUserToolLanguageFilter {
        
        let object = SwiftUserToolLanguageFilter()
        object.mapFrom(model: model)
        return object
    }
}

@available(iOS 17.4, *)
extension SwiftUserToolLanguageFilter {
 
    func toModel() -> UserToolLanguageFilterDataModel {
        return UserToolLanguageFilterDataModel(
            id: id,
            filterId: filterId,
            languageId: languageId,
            createdAt: createdAt
        )
    }
}
