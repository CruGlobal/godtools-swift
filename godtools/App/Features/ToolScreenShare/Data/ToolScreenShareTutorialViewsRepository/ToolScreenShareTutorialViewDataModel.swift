//
//  ToolScreenShareTutorialViewDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolScreenShareTutorialViewDataModel: Sendable {
    
    let id: String
    let numberOfViews: Int
    
    func copy(numberOfViews: Int? = nil) -> ToolScreenShareTutorialViewDataModel {
        return ToolScreenShareTutorialViewDataModel(
            id: id,
            numberOfViews: numberOfViews ?? self.numberOfViews
        )
    }
}
