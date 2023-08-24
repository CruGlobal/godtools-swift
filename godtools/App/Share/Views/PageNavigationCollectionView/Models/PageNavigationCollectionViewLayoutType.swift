//
//  PageNavigationCollectionViewLayoutType.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum PageNavigationCollectionViewLayoutType {
    
    case centeredRevealingPreviousAndNextPage(spacingBetweenPages: CGFloat, pageWidthAmountToRevealForPreviousAndNextPage: CGFloat)
    case fullScreen
}
