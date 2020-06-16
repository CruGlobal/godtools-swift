//
//  AttachmentFile.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct AttachmentFile {
    
    let attachmentId: String
    let sha256: String
    let pathExtension: String
    let remoteFileUrl: URL?
    
    init(attachment: RealmAttachment) {
        
        attachmentId = attachment.id
        sha256 = attachment.sha256
        remoteFileUrl = URL(string: attachment.file)
        pathExtension = remoteFileUrl?.pathExtension ?? ""
    }
}
