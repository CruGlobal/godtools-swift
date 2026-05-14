//
//  GetToolBannerUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 1/23/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class GetToolBannerUseCase {
    
    private let attachmentsRepository: AttachmentsRepository
    
    init(attachmentsRepository: AttachmentsRepository) {
        
        self.attachmentsRepository = attachmentsRepository
    }
    
    @MainActor func execute(attachmentId: String) async throws -> Data? {
        

        if let cachedImageData = try attachmentsRepository.getAttachment(id: attachmentId)?.getImageData() {
            return cachedImageData
        }
        
        return try await attachmentsRepository.getAttachmentFromCacheElseRemote(
            id: attachmentId,
            requestPriority: .high
        )?.getImageData()
    }
}
