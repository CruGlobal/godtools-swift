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
    
    private let attachmentsRepository: AttachmentsRepository
    private let attachmentId: String
    
    private var getBannerImageCancellable: AnyCancellable?
    
    @Published private(set) var bannerImageData: OptionalImageData?
    
    init(attachmentId: String, attachmentsRepository: AttachmentsRepository) {
        
        self.attachmentsRepository = attachmentsRepository
        self.attachmentId = attachmentId
        
        downloadAttachmentBanner(
            attachmentId: attachmentId
        )
    }
    
    private func downloadAttachmentBanner(attachmentId: String) {
        
        getBannerImageCancellable = nil
        
        do {
            
            let cachedAttachment: AttachmentDataModel? = try attachmentsRepository.cache.getAttachment(id: attachmentId)
            
            if let cachedImage = cachedAttachment?.getImage() {
                
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
        catch let error {
            assertionFailure("Failed to download banner attachment with error: \(error)")
        }
    }
}
