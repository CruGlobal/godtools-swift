//
//  GetShareableImageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import GodToolsToolParser

class GetShareableImageRepository: GetShareableImageRepositoryInterface {
    
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    init(resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.resourcesFileCache = resourcesFileCache
    }
    
    func getImagePublisher(shareable: ShareableDomainModel) -> AnyPublisher<ShareableImageDomainModel?, Never> {
        
        guard !shareable.imageName.isEmpty else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        let fileCacheLocation = FileCacheLocation(relativeUrlString: shareable.imageName)
        let image: SwiftUI.Image?
        
        switch resourcesFileCache.getImage(location: fileCacheLocation) {
        
        case .success(let cachedImage):
            image = cachedImage
        
        case .failure( _):
            image = nil
        }
        
        guard let image = image else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        let domainModel = ShareableImageDomainModel(
            dataModelId: shareable.imageName,
            image: image
        )
        
        return Just(domainModel)
            .eraseToAnyPublisher()
    }
}
