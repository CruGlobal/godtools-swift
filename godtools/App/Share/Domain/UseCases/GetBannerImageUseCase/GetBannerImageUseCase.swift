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
    
    init(attachmentsRepository: AttachmentsRepository) {
        
        self.attachmentsRepository = attachmentsRepository
    }
    
    func getBannerImagePublisher(for resourceId: String) -> AnyPublisher<Image?, Never> {
        
        return attachmentsRepository.getAttachmentImage(id: resourceId)
    }
}
