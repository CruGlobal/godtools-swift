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
    
    @MainActor func execute(attachmentId: String) -> AnyPublisher<Image?, Error> {
                
        let cachedAttachment: AttachmentDataModel? = attachmentsRepository
            .getAttachment(id: attachmentId)
                    
        if let cachedImage = cachedAttachment?.getImage() {
            
            return Just(cachedImage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else {
            
            return attachmentsRepository
                .getAttachmentFromCacheElseRemotePublisher(
                    id: attachmentId,
                    requestPriority: .high
                )
                .map { (attachment: AttachmentDataModel?) in
                    
                    return attachment?.getImage()
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}
