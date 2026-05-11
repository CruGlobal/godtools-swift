//
//  GetToolDetailsMediaUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolDetailsMediaUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let attachmentsRepository: AttachmentsRepository
    
    init(resourcesRepository: ResourcesRepository, attachmentsRepository: AttachmentsRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.attachmentsRepository = attachmentsRepository
    }
    
    func execute(toolId: String) -> AnyPublisher<ToolDetailsMediaDomainModel, Error> {
                
        return AnyPublisher() {
            return try await self.asyncExecute(toolId: toolId)
        }
    }
    
    func asyncExecute(toolId: String) async throws -> ToolDetailsMediaDomainModel {
        
        guard let resource = resourcesRepository.getResource(id: toolId) else {
            return .empty
        }
        
        if !resource.attrAboutOverviewVideoYoutube.isEmpty {
            
            return getYouTubeMedia(videoId: resource.attrAboutOverviewVideoYoutube)
        }
        else if !resource.attrAboutBannerAnimation.isEmpty {
            
            return try await getAnimatedMediaElseImageElseEmpty(resource: resource)
        }
        else {
            
            return try await getImageMediaElseEmpty(resource: resource)
        }
    }
    
    private func getYouTubeMedia(videoId: String) -> ToolDetailsMediaDomainModel {
        
        let playsInFullScreen: Int = 0
        let playerParameters: [String: Any] = [YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen]
        
        return .youtube(videoId: videoId, playerParameters: playerParameters)
    }
    
    private func getAnimatedMediaElseImageElseEmpty(resource: ResourceDataModel) async throws -> ToolDetailsMediaDomainModel {
        
        let attachment: AttachmentDataModel? = try await attachmentsRepository.getAttachmentFromCacheElseRemote(
            id: resource.attrAboutBannerAnimation,
            requestPriority: .high
        )
        
        guard let diskFileUrl = attachment?.storedAttachment?.diskFileUrl else {
            return try await getImageMediaElseEmpty(resource: resource)
        }
        
        let resource: AnimatedResource = .deviceFileManagerfilepathJsonFile(filepath: diskFileUrl.path)
        let viewModel = AnimatedViewModel(animationDataResource: resource, autoPlay: true, loop: true)
        
        return .animation(viewModel: viewModel)
    }
    
    private func getImageMediaElseEmpty(resource: ResourceDataModel) async throws -> ToolDetailsMediaDomainModel {
        
        let attachment: AttachmentDataModel? = try await attachmentsRepository.getAttachmentFromCacheElseRemote(
            id: resource.attrBannerAbout,
            requestPriority: .high
        )
        
        if let image = attachment?.getImage() {
            return .image(image: image)
        }
        
        return .empty
    }
    
    private func getEmptyMediaPublisher() -> AnyPublisher<ToolDetailsMediaDomainModel, Never> {
        
        return Just(.empty)
            .eraseToAnyPublisher()
    }
}
