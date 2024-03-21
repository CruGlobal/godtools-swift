//
//  GetShareableImageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetShareableImageUseCase {
    
    private let getShareableImageRepository: GetShareableImageRepositoryInterface
    
    init(getShareableImageRepository: GetShareableImageRepositoryInterface) {
        
        self.getShareableImageRepository = getShareableImageRepository
    }
    
    func getShareableImagePublisher(shareable: ShareableDomainModel) -> AnyPublisher<ShareableImageDomainModel?, Never> {
        
        return getShareableImageRepository
            .getImagePublisher(shareable: shareable)
            .eraseToAnyPublisher()
    }
}
