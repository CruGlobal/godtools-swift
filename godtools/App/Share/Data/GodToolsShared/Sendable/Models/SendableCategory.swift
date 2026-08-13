//
//  SendableCategory.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

extension GodToolsShared.Category {
    
    func toSendable() -> SendableCategory {
        return SendableCategory(
            id: self.id,
            labelText: self.label?.text,
            bannerLocation: self.banner?.toSHA256FileLocation()
        )
    }
}

struct SendableCategory: Sendable {
    
    let id: String?
    let labelText: String?
    let bannerLocation: FileCacheLocation?
}
