//
//  SHA256FileModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct SHA256FileModel: Sendable {
    
    let id: String
    let sha256WithPathExtension: String
    let attachments: [AttachmentDataModel]
    let translations: [TranslationDataModel]
}
