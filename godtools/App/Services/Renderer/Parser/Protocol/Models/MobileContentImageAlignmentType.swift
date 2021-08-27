//
//  MobileContentImageAlignmentType.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentImageAlignmentType {
    
    var isCenter: Bool { get }
    var isCenterX: Bool { get }
    var isCenterY: Bool { get }
    var isStart: Bool { get }
    var isEnd: Bool { get }
    var isTop: Bool { get }
    var isBottom: Bool { get }
}
