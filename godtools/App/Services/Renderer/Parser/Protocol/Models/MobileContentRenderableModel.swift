//
//  MobileContentRenderableModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

// TODO: I believe this can be removed now that we're using shared Kotlin parser. ~Levi
protocol MobileContentRenderableModel {
    
    // Actually, this is still needed. ~Levi
    func getRenderableChildModels() -> [MobileContentRenderableModel]
}

extension MobileContentRenderableModel {
    
    // TODO: Should I override this here or force concrete types to provide this or can this be shared between xml nodes and multiplatform. ~Levi
    // TODO: Let's remove this method here and force concrete types to provide this. ~Levi
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return Array()
    }
}
