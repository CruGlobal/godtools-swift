//
//  GetShareableImageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetShareableImageUseCase {
    
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    init(resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.resourcesFileCache = resourcesFileCache
    }
    
    func execute(shareable: ShareableDomainModel) -> AnyPublisher<ShareableImageDomainModel?, Error> {
        
        guard !shareable.imageName.isEmpty else {
            return getShareableImagePublisher(shareableImage: nil)
        }
        
        let fileCacheLocation = FileCacheLocation(relativeUrlString: shareable.imageName)
        
        do {
            
            let imageData: Data? = try resourcesFileCache.getData(location: fileCacheLocation)
           
            guard let imageData = imageData else {
                return getShareableImagePublisher(shareableImage: nil)
            }
            
            let shareableImage = ShareableImageDomainModel(
                dataModelId: shareable.imageName,
                imageData: imageData
            )
            
            return getShareableImagePublisher(shareableImage: shareableImage)
        }
        catch let error {
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private func getShareableImagePublisher(shareableImage: ShareableImageDomainModel?) -> AnyPublisher<ShareableImageDomainModel?, Error> {
        
        return Just(shareableImage)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
