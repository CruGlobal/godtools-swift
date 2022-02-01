//
//  MobileContentViewPositionState.swift
//  godtools
//
//  Created by Levi Eggert on 2/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentViewPositionState {
    
    private(set) var children: [MobileContentViewPositionState] = Array()
    
    func addChild(positionState: MobileContentViewPositionState) {
        
        children.append(positionState)
    }
}
