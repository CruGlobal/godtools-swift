//
//  ToolScreenShareInterfaceStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolScreenShareInterfaceStringsDomainModel {
    
    let generateQRCodeActionTitle: String
    let nextTutorialPageActionTitle: String
    let shareLinkActionTitle: String
    
    static var emptyStrings: ToolScreenShareInterfaceStringsDomainModel {
        return ToolScreenShareInterfaceStringsDomainModel(
            generateQRCodeActionTitle: "",
            nextTutorialPageActionTitle: "",
            shareLinkActionTitle: ""
        )
    }
}
