//
//  MobileContentPagePositionState.swift
//  godtools
//
//  Created by Levi Eggert on 2/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentPagePositionState: MobileContentViewPositionState {
    
    let scrollVerticalContentOffsetPercentageOfContentSize: CGFloat
    
    init(scrollVerticalContentOffsetPercentageOfContentSize: CGFloat) {
        
        self.scrollVerticalContentOffsetPercentageOfContentSize = scrollVerticalContentOffsetPercentageOfContentSize
    }
}
