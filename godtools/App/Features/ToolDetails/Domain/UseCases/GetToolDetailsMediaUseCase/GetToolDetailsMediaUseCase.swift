//
//  GetToolDetailsMediaUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsMediaUseCase {
    
    private let attachmentsRepository: AttachmentsRepository
    
    init(attachmentsRepository: AttachmentsRepository) {
        
        self.attachmentsRepository = attachmentsRepository
    }
    
    func getMedia(resource: ResourceModel) -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
                
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
        let playerParameters: [String: Any] = [Strings.YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen]
        
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
        
        return attachmentsRepository.getAttachmentImagePublisher(id: resource.attrBanner)
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
