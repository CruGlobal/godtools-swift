//
//  RealmToolScreenShareTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmToolScreenShareTutorialView: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var numberOfViews: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmToolScreenShareTutorialView {
    
    func mapFrom(model: ToolScreenShareTutorialViewDataModel) {
        
        id = model.id
        numberOfViews = model.numberOfViews
    }
    
    static func createNewFrom(model: ToolScreenShareTutorialViewDataModel) -> RealmToolScreenShareTutorialView {
        
        let object = RealmToolScreenShareTutorialView()
        object.mapFrom(model: model)
        return object
    }
}

extension RealmToolScreenShareTutorialView {
 
    func toModel() -> ToolScreenShareTutorialViewDataModel {
        return ToolScreenShareTutorialViewDataModel(
            id: id,
            numberOfViews: numberOfViews
        )
    }
}
