//
//  ShareToolScreenShareSessionStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ShareToolScreenShareSessionStringsDomainModel: Sendable {
    
    let shareMessage: String
    let qrCodeActionTitle: String
    
    static var emptyValue: ShareToolScreenShareSessionStringsDomainModel {
        return ShareToolScreenShareSessionStringsDomainModel(shareMessage: "", qrCodeActionTitle: "")
    }
}
