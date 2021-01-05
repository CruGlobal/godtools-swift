//
//  MobileContentBackgroundImageNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class MobileContentBackgroundImageNode: BackgroundImageNodeType {
    
    let backgroundImage: String?
    let backgroundImageAlign: String
    let backgroundImageScaleType: String
    
    required init(backgroundImage: String?, backgroundImageAlign: String, backgroundImageScaleType: String) {
        
        self.backgroundImage = backgroundImage
        self.backgroundImageAlign = backgroundImageAlign
        self.backgroundImageScaleType = backgroundImageScaleType
    }
}
