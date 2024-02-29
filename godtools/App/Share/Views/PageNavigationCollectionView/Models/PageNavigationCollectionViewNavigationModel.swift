//
//  PageNavigationCollectionViewNavigationModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import UIKit

struct PageNavigationCollectionViewNavigationModel {
    
    let navigationDirection: UISemanticContentAttribute?
    let page: Int
    let animated: Bool
    let reloadCollectionViewDataNeeded: Bool
    let insertPages: [Int]?
    let deletePages: [Int]?
    
    var hasPagesToInsert: Bool {
        
        guard let insertPages = self.insertPages else {
            return false
        }
        
        return !insertPages.isEmpty
    }
    
    var hasPagesToDelete: Bool {
        
        guard let deletePages = self.deletePages else {
            return false
        }
        
        return !deletePages.isEmpty
    }
}
