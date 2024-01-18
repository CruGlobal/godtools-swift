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
    
    func getMediaPublisher(tool: ToolDomainModel) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
                
        guard let resource = resourcesRepository.getResource(id: tool.dataModelId) else {
            return Just(.empty)
                .eraseToAnyPublisher()
        }
        
        if !resource.attrAboutOverviewVideoYoutube.isEmpty {
            
            return getYouTubeMedia(videoId: resource.attrAboutOverviewVideoYoutube)
        }
        else if !resource.attrAboutBannerAnimation.isEmpty {
            
            return getAnimatedMediaElseImage(resource: resource)
        }
        else {
            
            return getImageMediaElseEmpty(resource: resource)
        }
    }
    
    private func getYouTubeMedia(videoId: String) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
        
        let playsInFullScreen: Int = 0
        let playerParameters: [String: Any] = [YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen]
        
        return Just(.youtube(videoId: videoId, playerParameters: playerParameters))
            .eraseToAnyPublisher()
    }
    
    private func getAnimatedMediaElseImage(resource: ResourceModel) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
        
        return attachmentsRepository.getAttachmentUrlPublisher(id: resource.attrAboutBannerAnimation)
            .flatMap({ url -> AnyPublisher<ToolDetailsMediaDomainModel, Never> in
                
                guard let url = url else {
                    return self.getImageMediaElseEmpty(resource: resource)
                }
                
                let resource: AnimatedResource = .deviceFileManagerfilepathJsonFile(filepath: url.path)
                let viewModel = AnimatedViewModel(animationDataResource: resource, autoPlay: true, loop: true)
                
                return Just(.animation(viewModel: viewModel))
                    .eraseToAnyPublisher()

            })
            .eraseToAnyPublisher()
    }
    
    private func getImageMediaElseEmpty(resource: ResourceModel) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
        
        return attachmentsRepository.getAttachmentImagePublisher(id: resource.attrBannerAbout)
            .flatMap({ image -> AnyPublisher<ToolDetailsMediaDomainModel, Never> in
                
                guard let image = image else {
                    return self.getEmptyMedia()
                }
                
                return Just(.image(image: image))
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getEmptyMedia() -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
        
        return Just(.empty)
            .eraseToAnyPublisher()
    }
}
