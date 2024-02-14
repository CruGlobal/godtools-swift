//
//  FavoritedToolsLatestToolDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class FavoritedToolsLatestToolDownloader: FavoritedToolsLatestToolDownloaderInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let resourcesRepository: ResourcesRepository
    private let toolDownloader: ToolDownloader
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, toolDownloader: ToolDownloader) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.toolDownloader = toolDownloader
    }
    
    func downloadLatestToolsPublisher(inLanguages: [BCP47LanguageIdentifier]) -> AnyPublisher<Void, Never> {
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChangedPublisher(),
            favoritedResourcesRepository.getFavoritedResourcesChangedPublisher()
        )
        .flatMap({ (resourcesChanged: Void, favoritedResourcesChanged: Void) -> AnyPublisher<[FavoritedResourceDataModel], Never> in
            
            let favoritedTools: [FavoritedResourceDataModel] = self.favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
            
            return Just(favoritedTools)
                .eraseToAnyPublisher()
        })
        .flatMap({ (favoritedTools: [FavoritedResourceDataModel]) -> AnyPublisher<[DownloadToolDataModel], Never> in
            
            let tools: [DownloadToolDataModel] = favoritedTools.map({
                DownloadToolDataModel(
                    toolId: $0.id,
                    languages: inLanguages
                )
            })
            
            return Just(tools)
                .eraseToAnyPublisher()
        })
        .flatMap({ (tools: [DownloadToolDataModel]) -> AnyPublisher<Void, Never> in
                        
            return self.toolDownloader
                .downloadToolsPublisher(tools: tools)
                .map { _ in
                    return Void()
                }
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
