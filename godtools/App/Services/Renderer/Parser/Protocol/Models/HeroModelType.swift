//
//  HeroModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol HeroModelType: MobileContentRenderableModel {
    
    func getAnalyticsEvents() -> [AnalyticsEventModelType]
}

extension HeroModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
