//
//  ShareToolQRCodeStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ShareToolQRCodeStringsDomainModel: Sendable {
    
    let message: String
    let closeActionTitle: String
    
    static var emptyValue: ShareToolQRCodeStringsDomainModel {
        return ShareToolQRCodeStringsDomainModel(message: "", closeActionTitle: "")
    }
}
