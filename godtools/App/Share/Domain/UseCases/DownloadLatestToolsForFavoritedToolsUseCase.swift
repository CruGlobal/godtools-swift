//
//  DownloadLatestToolsForFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class DownloadLatestToolsForFavoritedToolsUseCase {
    
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
            resourcesRepository.persistence.observeCollectionChangesPublisher(),
            favoritedResourcesRepository
                .getFavoritedResourcesSortedByPositionPublisher()
                .setFailureType(to: Error.self)
        )
        .flatMap({ (resourcesChanged: Void, favoritedTools: [FavoritedResourceDataModel]) -> AnyPublisher<[DownloadToolDataModel], Error> in
                        
            let tools: [DownloadToolDataModel] = favoritedTools.map({
                DownloadToolDataModel(
                    toolId: $0.id,
                    languages: [appLanguage]
                )
            })
            
            return Just(tools)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        })
        .flatMap({ (tools: [DownloadToolDataModel]) -> AnyPublisher<Void, Error> in
                        
            return self.toolDownloader
                .downloadToolsPublisher(tools: tools, requestPriority: .medium)
                .map { _ in
                    return Void()
                }
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
