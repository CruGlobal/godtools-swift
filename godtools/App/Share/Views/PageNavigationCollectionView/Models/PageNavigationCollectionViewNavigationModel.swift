//
//  PageNavigationCollectionViewNavigationModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import UIKit

class PageNavigationCollectionViewNavigationModel {
    
    let navigationDirection: UISemanticContentAttribute
    let page: Int
    let animated: Bool
    let reloadCollectionViewDataNeeded: Bool
    
    init(navigationDirection: UISemanticContentAttribute, page: Int, animated: Bool, reloadCollectionViewDataNeeded: Bool) {
        
        self.navigationDirection = navigationDirection
        self.page = page
        self.animated = animated
        self.reloadCollectionViewDataNeeded = reloadCollectionViewDataNeeded
    }
    
    init(navigationDirection: UISemanticContentAttribute, page: Int, animated: Bool) {
        
        self.navigationDirection = navigationDirection
        self.page = page
        self.animated = animated
        self.reloadCollectionViewDataNeeded = false
    }
    
    init(page: Int, animated: Bool) {
        
        self.navigationDirection = .forceLeftToRight
        self.page = page
        self.animated = animated
        self.reloadCollectionViewDataNeeded = false
    }
}
