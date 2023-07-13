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
}
