//
//  DismissToolEvent.swift
//  godtools
//
//  Created by Levi Eggert on 6/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct DismissToolEvent: Sendable {
    
    let resource: ResourceDataModel
    let language: AppLanguageDomainModel
    let highestPageNumberViewed: Int
}
