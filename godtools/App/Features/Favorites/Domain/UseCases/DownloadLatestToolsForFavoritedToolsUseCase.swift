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
    
    init(
        favoritedResourcesRepository: FavoritedResourcesRepository,
        resourcesRepository: ResourcesRepository,
        toolDownloader: ToolDownloader
    ) {
        
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
        .flatMap { (resourcesChanged: Void, favoritedResourcesChanged: Void) -> AnyPublisher<Void, Error> in
                        
            return AnyPublisher() {
                try await self.asyncExecute(appLanguage: appLanguage)
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async throws {
        
        let favoritedTools: [FavoritedResourceDataModel] = try await favoritedResourcesRepository.getFavoritedResourcesSortedByPosition()
        
        let tools: [DownloadToolData] = favoritedTools.map({
            DownloadToolData(
                toolId: $0.id,
                languages: [appLanguage]
            )
        })
        
        _ = await toolDownloader.downloadTools(tools: tools, requestPriority: .medium)
    }
}
