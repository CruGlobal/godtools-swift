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
    private let translationsRepository: TranslationsRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
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
        .flatMap({ (favoritedTools: [FavoritedResourceDataModel]) -> AnyPublisher<[TranslationModel], Never> in
            
            var translations: [TranslationModel] = Array()
            
            guard !favoritedTools.isEmpty && !inLanguages.isEmpty else {
                return Just(translations)
                    .eraseToAnyPublisher()
            }
           
            for favoritedTool in favoritedTools {
                
                for languageIdentifier in inLanguages {
                    
                    guard let translation = self.translationsRepository.getLatestTranslation(resourceId: favoritedTool.id, languageCode: languageIdentifier) else {
                        continue
                    }
                    
                    translations.append(translation)
                }
            }
            
            return Just(translations)
                .eraseToAnyPublisher()
        })
        .flatMap({ (translations: [TranslationModel]) -> AnyPublisher<Void, Never> in
                        
            return self.translationsRepository
                .downloadAndCacheFilesForTranslationsIgnoringError(translations: translations)
                .map { _ in
                    return Void()
                }
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
