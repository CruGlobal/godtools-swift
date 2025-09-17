//
//  DismissToolEvent.swift
//  godtools
//
//  Created by Levi Eggert on 6/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DismissToolEvent {
    
    let resource: ResourceDataModel
    let highestPageNumberViewed: Int
    
    init(resource: ResourceDataModel, highestPageNumberViewed: Int) {
        
        self.resource = resource
        self.highestPageNumberViewed = highestPageNumberViewed
    }
}
