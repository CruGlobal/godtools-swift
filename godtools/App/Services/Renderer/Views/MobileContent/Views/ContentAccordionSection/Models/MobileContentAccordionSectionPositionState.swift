//
//  MobileContentAccordionSectionPositionState.swift
//  godtools
//
//  Created by Levi Eggert on 5/9/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class MobileContentAccordionSectionPositionState: MobileContentViewPositionState {
        
    let contentIsHidden: Bool
    
    init(contentIsHidden: Bool) {
        
        self.contentIsHidden = contentIsHidden
    }
}
