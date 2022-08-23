//
//  SHA256FileModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct SHA256FileModel: SHA256FileModelType {
    
    let sha256WithPathExtension: String
    let attachments: [AttachmentModel]
    let translations: [TranslationModel]
    
    init(realmSHA256File: RealmSHA256File) {
        
        sha256WithPathExtension = realmSHA256File.sha256WithPathExtension
        attachments = Array(realmSHA256File.attachments).map({AttachmentModel(model: $0)})
        translations = Array(realmSHA256File.translations).map({TranslationModel(model: $0)})
    }
}
