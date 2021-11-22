//
//  TutorialModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TutorialModel {
    
    let tutorialItems: [TutorialItemType]
    
    required init(tutorialItems: [TutorialItemType]) {
        
        self.tutorialItems = tutorialItems
    }
}

