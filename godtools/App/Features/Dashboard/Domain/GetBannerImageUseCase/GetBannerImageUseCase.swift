//
//  GetBannerImageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/8/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class GetBannerImageUseCase {
    
    private let attachmentsRepository: AttachmentsRepository
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(attachmentsRepository: AttachmentsRepository) {
        
        self.attachmentsRepository = attachmentsRepository
    }
    
    func getBannerImagePublisher(for attachmentId: String) -> AnyPublisher<Image?, Never> {
        
        let cachedImage: Image? = attachmentsRepository.getAttachmentImageFromCache(id: attachmentId)
        
        return attachmentsRepository.getAttachmentImagePublisher(id: attachmentId).prepend(cachedImage)
            .eraseToAnyPublisher()
    }
}
