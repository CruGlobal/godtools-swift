//
//  GetToolDetailsMediaRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsMediaRepository: GetToolDetailsMediaRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let attachmentsRepository: AttachmentsRepository
    
    init(resourcesRepository: ResourcesRepository, attachmentsRepository: AttachmentsRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.attachmentsRepository = attachmentsRepository
    }
    
    @MainActor func getMediaPublisher(toolId: String) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
                
        guard let resource = resourcesRepository.persistence.getDataModelNonThrowing(id: toolId) else {
            return Just(.empty)
                .eraseToAnyPublisher()
        }
        
        if !resource.attrAboutOverviewVideoYoutube.isEmpty {
            
            return getYouTubeMedia(videoId: resource.attrAboutOverviewVideoYoutube)
        }
        else if !resource.attrAboutBannerAnimation.isEmpty {
            
            return getAnimatedMediaElseImage(resource: resource)
                .catch { _ in
                    return Just(.empty)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        else {
            
            return getImageMediaElseEmpty(resource: resource)
                .catch { _ in
                    return Just(.empty)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }
    
    private func getYouTubeMedia(videoId: String) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
        
        let playsInFullScreen: Int = 0
        let playerParameters: [String: Any] = [YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen]
        
        return Just(.youtube(videoId: videoId, playerParameters: playerParameters))
            .eraseToAnyPublisher()
    }
    
    @MainActor private func getAnimatedMediaElseImage(resource: ResourceDataModel) -> AnyPublisher<ToolDetailsMediaDomainModel, Error> {
        
        return attachmentsRepository.getAttachmentFromCacheElseRemotePublisher(id: resource.attrAboutBannerAnimation, requestPriority: .high)
            .flatMap({ (attachment: AttachmentDataModel?) -> AnyPublisher<ToolDetailsMediaDomainModel, Error> in
                
                guard let diskFileUrl = attachment?.storedAttachment?.diskFileUrl else {
                    return self.getImageMediaElseEmpty(resource: resource)
                }
                
                let resource: AnimatedResource = .deviceFileManagerfilepathJsonFile(filepath: diskFileUrl.path)
                let viewModel = AnimatedViewModel(animationDataResource: resource, autoPlay: true, loop: true)
                
                return Just(.animation(viewModel: viewModel))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()

            })
            .eraseToAnyPublisher()
    }
    
    @MainActor private func getImageMediaElseEmpty(resource: ResourceDataModel) -> AnyPublisher<ToolDetailsMediaDomainModel, Error> {
        
        return attachmentsRepository.getAttachmentFromCacheElseRemotePublisher(id: resource.attrBannerAbout, requestPriority: .high)
            .flatMap({ (attachment: AttachmentDataModel?) -> AnyPublisher<ToolDetailsMediaDomainModel, Error> in
                
                guard let image = attachment?.getImage() else {
                    return self.getEmptyMedia()
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return Just(.image(image: image))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getEmptyMedia() -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
        
        return Just(.empty)
            .eraseToAnyPublisher()
    }
}
