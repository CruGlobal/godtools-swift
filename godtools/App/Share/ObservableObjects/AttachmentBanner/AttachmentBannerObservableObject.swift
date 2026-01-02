//
//  AttachmentBannerObservableObject.swift
//  godtools
//
//  Created by Levi Eggert on 9/17/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class AttachmentBannerObservableObject: ObservableObject {
    
    private var getBannerImageCancellable: AnyCancellable?
    
    @Published private(set) var bannerImageData: OptionalImageData?
    
    init(attachmentId: String, attachmentsRepository: AttachmentsRepository) {
        
        getBannerImageCancellable = nil
                
        if let cachedAttachment = attachmentsRepository.cache.getAttachment(id: attachmentId),
           let cachedImage = cachedAttachment.getImage() {
            
            bannerImageData = OptionalImageData(image: cachedImage, imageIdForAnimationChange: attachmentId)
        }
        else {
            
            getBannerImageCancellable = attachmentsRepository.getAttachmentFromCacheElseRemotePublisher(id: attachmentId, requestPriority: .high)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { [weak self] (attachment: AttachmentDataModel?) in
                   
                    self?.bannerImageData = OptionalImageData(image: attachment?.getImage(), imageIdForAnimationChange: attachmentId)
                })
        }
    }
}
