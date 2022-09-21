//
//  DownloadedAttachmentResult.swift
//  godtools
//
//  Created by Levi Eggert on 7/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated)
class DownloadedAttachmentResult {
    
    let attachmentFile: AttachmentFile
    let downloadError: AttachmentsDownloaderError?
    
    required init(attachmentFile: AttachmentFile, downloadError: AttachmentsDownloaderError?) {
        
        self.attachmentFile = attachmentFile
        self.downloadError = downloadError
    }
}
