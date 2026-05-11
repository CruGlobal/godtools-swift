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
    
    @MainActor func execute(attachmentId: String) async throws -> Image? {
        
        if let cachedImage = try attachmentsRepository.getAttachment(id: attachmentId)?.getImage() {
            return cachedImage
        }
        
        return try await attachmentsRepository.getAttachmentFromCacheElseRemote(
            id: attachmentId,
            requestPriority: .high
        )?.getImage()
    }
}
