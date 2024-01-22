//
//  PageNavigationCollectionViewFlowLayout.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit

class PageNavigationCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        
        // NOTE: Settings this to true will cause the coordinate system to flip when the device system language is right to left.  Meaning the contentOffset will flip.
        // Without setting this to true, when the device language is right to left, the collection view will correctly call cellForRow at 0 and scroll right to left correctly.  However,
        // the contentOffset wouldn't start at 0 and would instead start at the end as if the collectionView were scrolling left to right. ~Levi
        
        return true
    }
}
