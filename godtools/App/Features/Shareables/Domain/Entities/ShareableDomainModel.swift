//
//  ShareableDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ShareableDomainModel {
    
    let dataModelId: String
    let imageName: String
    let title: String
}

extension ShareableDomainModel: Identifiable {
    var id: String {
        return dataModelId
    }
}
