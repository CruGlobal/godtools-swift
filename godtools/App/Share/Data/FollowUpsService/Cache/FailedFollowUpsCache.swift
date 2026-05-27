//
//  FailedFollowUpsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class FailedFollowUpsCache {
    
    let persistence: any Persistence<FollowUpDataModel, FollowUpDataModel>
    
    init(persistence: any Persistence<FollowUpDataModel, FollowUpDataModel>) {
        
        self.persistence = persistence
    }
}
