//
//  Manifest+Categories.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

extension GodToolsShared.Manifest {
    
    var sendableCategories: [Category] {
        return categories.map {
            $0.toSendable()
        }
    }
}
