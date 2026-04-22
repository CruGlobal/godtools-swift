//
//  SwiftToolScreenTutorialShareView.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftToolScreenTutorialShareView = SwiftToolScreenTutorialShareViewV1.SwiftToolScreenTutorialShareView

@available(iOS 17.4, *)
enum SwiftToolScreenTutorialShareViewV1 {
 
    @Model
    class SwiftToolScreenTutorialShareView: IdentifiableSwiftDataObject {
        
        var numberOfViews: Int = 0
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftToolScreenTutorialShareView {
    
    func mapFrom(model: ToolScreenShareTutorialViewDataModel) {
        
        id = model.id
        numberOfViews = model.numberOfViews
    }
    
    static func createNewFrom(model: ToolScreenShareTutorialViewDataModel) -> SwiftToolScreenTutorialShareView {
        
        let object = SwiftToolScreenTutorialShareView()
        object.mapFrom(model: model)
        return object
    }
}

@available(iOS 17.4, *)
extension SwiftToolScreenTutorialShareView {
 
    func toModel() -> ToolScreenShareTutorialViewDataModel {
        return ToolScreenShareTutorialViewDataModel(
            id: id,
            numberOfViews: numberOfViews
        )
    }
}
