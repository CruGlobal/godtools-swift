//
//  SharableDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct SharableDomainModel {
    
    let dataModelId: String
    let title: String
}

extension SharableDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
