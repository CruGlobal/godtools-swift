//
//  ShareToolStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ShareToolStringsDomainModel: Sendable {
    
    let shareMessage: String
    let qrCodeActionTitle: String
    
    static var emptyValue: ShareToolStringsDomainModel {
        return ShareToolStringsDomainModel(shareMessage: "", qrCodeActionTitle: "")
    }
}
