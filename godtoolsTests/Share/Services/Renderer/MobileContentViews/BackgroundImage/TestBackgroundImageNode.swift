//
//  TestBackgroundImageNode.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/4/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TestBackgroundImageNode: BackgroundImageNodeType {
    
    let backgroundImage: String? = nil
    let backgroundImageAlign: [String]
    let backgroundImageScaleType: String
    
    required init(backgroundImageAlign: [String], backgroundImageScaleType: String) {
        
        self.backgroundImageAlign = backgroundImageAlign
        self.backgroundImageScaleType = backgroundImageScaleType
    }
}
