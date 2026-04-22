//
//  SwiftResourceView.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftResourceView = SwiftResourceViewV1.SwiftResourceView

@available(iOS 17.4, *)
enum SwiftResourceViewV1 {
 
    @Model
    class SwiftResourceView: IdentifiableSwiftDataObject {
        
        var quantity: Int = 0
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var resourceId: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftResourceView {
    
    func mapFrom(model: ResourceViewsDataModel) {
        id = model.id
        resourceId = model.resourceId
        quantity = model.quantity
    }
    
    static func createNewFrom(model: ResourceViewsDataModel) -> SwiftResourceView {
        let object = SwiftResourceView()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> ResourceViewsDataModel {
        return ResourceViewsDataModel(
            id: id,
            resourceId: resourceId,
            quantity: quantity
        )
    }
}
