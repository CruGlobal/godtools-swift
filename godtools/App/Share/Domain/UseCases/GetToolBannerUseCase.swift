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
    
    func execute(attachmentId: String) -> AnyPublisher<Image?, Error> {
                
        AnyPublisher() {
            return try await self.asyncExecute(attachmentId: attachmentId)
        }
    }
    
    func asyncExecute(attachmentId: String) async throws -> Image? {
        
        let cachedAttachment = try attachmentsRepository.getAttachment(id: attachmentId)
        
        if let image = cachedAttachment?.getImage() {
            return image
        }
        
        let attachment = try await attachmentsRepository.getAttachmentFromCacheElseRemote(
            id: attachmentId,
            requestPriority: .high
        )
        
        return attachment?.getImage()
    }
}
