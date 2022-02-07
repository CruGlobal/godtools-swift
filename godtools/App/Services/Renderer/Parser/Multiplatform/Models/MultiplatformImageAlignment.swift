//
//  MultiplatformImageAlignment.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

struct MultiplatformImageAlignment: MobileContentImageAlignmentType {
    
    let isCenter: Bool
    let isCenterX: Bool
    let isCenterY: Bool
    let isStart: Bool
    let isEnd: Bool
    let isTop: Bool
    let isBottom: Bool
    
    init(imageGravity: Gravity) {
        
        isCenter = imageGravity.isCenter
        isCenterX = imageGravity.isCenterX
        isCenterY = imageGravity.isCenterY
        isStart = imageGravity.isStart
        isEnd = imageGravity.isEnd
        isTop = imageGravity.isTop
        isBottom = imageGravity.isBottom
    }
}
