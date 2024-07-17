//
//  MobileContentStackPositionState.swift
//  godtools
//
//  Created by Levi Eggert on 5/9/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class MobileContentStackPositionState: MobileContentViewPositionState {
    
    let scrollViewContentOffset: CGPoint?
    let scrollViewContentSize: CGSize?
    
    init(scrollViewContentOffset: CGPoint?, scrollViewContentSize: CGSize?) {
        
        self.scrollViewContentOffset = scrollViewContentOffset
        self.scrollViewContentSize = scrollViewContentSize
    }
}
