//
//  RealmResourcesCacheResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct RealmResourcesCacheResult {
    
    typealias SHA256 = String
    
    let attachmentFileGroups: [SHA256: [AttachmentFile]]
}
