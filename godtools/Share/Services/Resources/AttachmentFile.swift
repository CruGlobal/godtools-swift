//
//  AttachmentFile.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AttachmentFile {
    
    private(set) var relatedAttachmentIds: [String] = Array()
    
    let remoteFileUrl: URL
    let sha256: String
    let pathExtension: String
    let location: SHA256FileLocation
    
    required init(remoteFileUrl: URL, sha256: String, pathExtension: String) {
        
        self.remoteFileUrl = remoteFileUrl
        self.sha256 = sha256
        self.pathExtension = pathExtension
        self.location = SHA256FileLocation(sha256: sha256, pathExtension: pathExtension)
    }
    
    var sha256WithPathExtension: String {
        if !pathExtension.isEmpty {
            return sha256 + "." + pathExtension
        }
        return sha256
    }
    
    func addAttachmentId(attachmentId: String) {
        if !relatedAttachmentIds.contains(attachmentId) {
            relatedAttachmentIds.append(attachmentId)
        }
    }
}

extension AttachmentFile: Equatable {
    static func ==(lhs: AttachmentFile, rhs: AttachmentFile) -> Bool {
        return lhs.sha256 == rhs.sha256 && lhs.pathExtension == rhs.pathExtension
    }
}
