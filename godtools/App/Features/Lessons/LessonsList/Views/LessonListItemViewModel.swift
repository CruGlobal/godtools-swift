//
//  LessonListItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonListItemViewModel: LessonListItemViewModelType {
    
    private let resource: ResourceModel
    
    required init(resource: ResourceModel) {
        
        self.resource = resource
    }
}
