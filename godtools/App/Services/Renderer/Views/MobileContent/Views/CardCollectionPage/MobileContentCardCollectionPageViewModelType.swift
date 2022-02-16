//
//  MobileContentCardCollectionPageViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol MobileContentCardCollectionPageViewModelType: MobileContentPageViewModelType {
    
    func pageDidAppear()
    func cardDidAppear(card: Int)
}
