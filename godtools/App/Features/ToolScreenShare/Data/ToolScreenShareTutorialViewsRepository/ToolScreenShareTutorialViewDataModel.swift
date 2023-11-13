//
//  ToolScreenShareTutorialViewDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolScreenShareTutorialViewDataModel {
    
    let id: String
    let numberOfViews: Int
    
    init(id: String, numberOfViews: Int) {
        
        self.id = id
        self.numberOfViews = numberOfViews
    }
    
    init(realmToolScreenShareView: RealmToolScreenShareTutorialView) {
            
        self.id = realmToolScreenShareView.id
        self.numberOfViews = realmToolScreenShareView.numberOfViews
    }
}
