//
//  ToolScreenShareQRCodeStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ToolScreenShareQRCodeStringsDomainModel: Sendable {
    
    let qrCodeDescription: String
    let closeButtonTitle: String
    
    static var emptyValue: ToolScreenShareQRCodeStringsDomainModel {
        return ToolScreenShareQRCodeStringsDomainModel(qrCodeDescription: "", closeButtonTitle: "")
    }
}
