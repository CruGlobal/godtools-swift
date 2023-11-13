//
//  ToolScreenShareViewDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolScreenShareViewDataModel {
    
    let id: String
    let numberOfViews: Int
    
    init(id: String, numberOfViews: Int) {
        
        self.id = id
        self.numberOfViews = numberOfViews
    }
    
    init(realmToolScreenShareView: RealmToolScreenShareView) {
            
        self.id = realmToolScreenShareView.id
        self.numberOfViews = realmToolScreenShareView.numberOfViews
    }
}
