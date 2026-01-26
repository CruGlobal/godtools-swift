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
    
    private let getShareableImageRepository: GetShareableImageRepository
    
    init(getShareableImageRepository: GetShareableImageRepository) {
        
        self.getShareableImageRepository = getShareableImageRepository
    }
    
    func execute(shareable: ShareableDomainModel) -> AnyPublisher<ShareableImageDomainModel?, Error> {
        
        do {
            
            let domainModel: ShareableImageDomainModel? = try getShareableImageRepository.getImageDomainModel(
                shareable: shareable
            )
            
            return Just(domainModel)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
