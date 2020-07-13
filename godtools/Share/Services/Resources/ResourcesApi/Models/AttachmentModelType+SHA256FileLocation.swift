//
//  AttachmentModelType+SHA256FileLocation.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension AttachmentModelType {
    
    var sha256FileLocation: SHA256FileLocation {
        return SHA256FileLocation(
            sha256: sha256,
            pathExtension: URL(string: file)?.pathExtension ?? ""
        )
    }
}
