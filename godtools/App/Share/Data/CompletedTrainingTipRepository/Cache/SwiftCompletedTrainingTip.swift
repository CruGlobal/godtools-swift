//
//  SwiftCompletedTrainingTip.swift
//  godtools
//
//  Created by Rachael Skeath on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftCompletedTrainingTip = SwiftCompletedTrainingTipV1.SwiftCompletedTrainingTip

@available(iOS 17.4, *)
enum SwiftCompletedTrainingTipV1 {
    
    @Model
    class SwiftCompletedTrainingTip: IdentifiableSwiftDataObject {
        
        var trainingTipId: String = ""
        var resourceId: String = ""
        var languageId: String = ""
        
        @Attribute(.unique) var id: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftCompletedTrainingTip {
    
    public static func idPredicate(id: String) -> Predicate<SwiftCompletedTrainingTip> {
        return #Predicate<SwiftCompletedTrainingTip> { object in
            object.id == id
        }
    }

    public static func idsPredicate(ids: Set<String>) -> Predicate<SwiftCompletedTrainingTip> {
        return #Predicate<SwiftCompletedTrainingTip> { object in
            ids.contains(object.id)
        }
    }
    
    func mapFrom(model: CompletedTrainingTipDataModel) {
        
        id = model.id.value
        trainingTipId = model.id.trainingTipId
        resourceId = model.id.resourceId
        languageId = model.id.languageId
    }
    
    static func createNewFrom(model: CompletedTrainingTipDataModel) -> SwiftCompletedTrainingTip {
        let object = SwiftCompletedTrainingTip()
        object.mapFrom(model: model)
        return object
    }
   
    func toModel() -> CompletedTrainingTipDataModel {
        return CompletedTrainingTipDataModel(
            id: TrainingTipId(
                trainingTipId: trainingTipId,
                languageId: languageId,
                resourceId: resourceId
            )
        )
    }
}
