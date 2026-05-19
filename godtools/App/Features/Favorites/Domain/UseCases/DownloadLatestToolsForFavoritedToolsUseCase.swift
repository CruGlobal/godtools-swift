//
//  DownloadLatestToolsForFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class DownloadLatestToolsForFavoritedToolsUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let toolDownloader: ToolDownloader
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, toolDownloader: ToolDownloader) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.toolDownloader = toolDownloader
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<Void, Error> {
        
        return Publishers.CombineLatest(
            resourcesRepository
                .observeCollectionChangesPublisher(),
            favoritedResourcesRepository
                .observeCollectionChangesPublisher()
        )
        .flatMap { (resourcesChanged: Void, favoritedResourcesChanged: Void) -> AnyPublisher<[FavoritedResourceDataModel], Error> in
                        
            return self.favoritedResourcesRepository
                .getFavoritedResourcesSortedByPositionPublisher()
        }
        .flatMap { (favoritedTools: [FavoritedResourceDataModel]) -> AnyPublisher<[DownloadToolData], Error> in
                        
            let tools: [DownloadToolData] = favoritedTools.map({
                DownloadToolData(
                    toolId: $0.id,
                    languages: [appLanguage]
                )
            })
            
            return Just(tools)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        .flatMap { (tools: [DownloadToolData]) -> AnyPublisher<Void, Error> in
                
            return AnyPublisher() {
                try await self.toolDownloader
                    .downloadTools(
                        tools: tools,
                        requestPriority: .medium
                    )
            }
        }
        .eraseToAnyPublisher()
    }
}
