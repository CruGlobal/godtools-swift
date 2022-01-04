//
//  AttachmentsDownloaderError.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

enum AttachmentsDownloaderError: Error {
    
    case failedToCacheAttachment(error: Error)
    case failedToDownloadAttachment(error: RequestResponseError<NoHttpClientErrorResponse>)
    case noAttachmentData(missingAttachmentData: NoAttachmentData)
}
