//
//  AttachmentsApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol AttachmentsApiInterface: Sendable {
    
    func getAttachmentFile(url: URL, requestPriority: RequestPriority) async throws -> RequestDataResponse
}
