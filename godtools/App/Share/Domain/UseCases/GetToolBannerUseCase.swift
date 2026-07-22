//
//  GetToolBannerUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 1/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI

final class GetToolBannerUseCase {
    
    private let attachmentsRepository: AttachmentsRepository
    
    init(attachmentsRepository: AttachmentsRepository) {
        
        self.attachmentsRepository = attachmentsRepository
    }
    
    func execute(attachmentId: String) async throws -> Data? {
        
        if let cachedImageData = attachmentsRepository.getAttachment(id: attachmentId)?.getImageData() {
            return cachedImageData
        }
        
        return try await attachmentsRepository.getAttachmentFromCacheElseRemote(
            id: attachmentId,
            requestPriority: .high
        )?.getImageData()
    }
}
