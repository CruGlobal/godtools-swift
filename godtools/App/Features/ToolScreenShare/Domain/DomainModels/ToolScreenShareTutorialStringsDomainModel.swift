//
//  ToolScreenShareTutorialStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolScreenShareTutorialStringsDomainModel: Sendable {
    
    let generateQRCodeActionTitle: String
    let nextTutorialPageActionTitle: String
    let shareLinkActionTitle: String
    
    static var emptyValue: ToolScreenShareTutorialStringsDomainModel {
        return ToolScreenShareTutorialStringsDomainModel(
            generateQRCodeActionTitle: "",
            nextTutorialPageActionTitle: "",
            shareLinkActionTitle: ""
        )
    }
}
