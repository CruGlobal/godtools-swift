//
//  LocalActivityCountDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct LocalActivityCountDataModel: Sendable {
    
    let id: String
    let count: Int
    
    func copy(count: Int?) -> LocalActivityCountDataModel {
        return LocalActivityCountDataModel(
            id: id,
            count: count ?? self.count
        )
    }
}
