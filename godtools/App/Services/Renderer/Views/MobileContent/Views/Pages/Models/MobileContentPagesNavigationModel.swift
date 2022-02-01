//
//  MobileContentPagesNavigationModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct MobileContentPagesNavigationModel {
    
    let willReloadData: Bool
    let page: Int
    let pagePositions: MobileContentViewPositionState?
    let animated: Bool
}
