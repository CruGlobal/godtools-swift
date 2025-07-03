//
//  ToolScreenShareQRCodeInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct ToolScreenShareQRCodeInterfaceStringsDomainModel {
    let qrCodeDescription: String
    let closeButtonTitle: String
    
    static func emptyStrings() -> ToolScreenShareQRCodeInterfaceStringsDomainModel {
        return ToolScreenShareQRCodeInterfaceStringsDomainModel(qrCodeDescription: "", closeButtonTitle: "")
    }
}
