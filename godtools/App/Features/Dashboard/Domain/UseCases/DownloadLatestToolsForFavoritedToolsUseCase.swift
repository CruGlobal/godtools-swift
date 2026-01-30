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
    
    private let latestToolDownloader: FavoritedToolsLatestToolDownloaderInterface
    
    init(latestToolDownloader: FavoritedToolsLatestToolDownloaderInterface) {
        
        self.latestToolDownloader = latestToolDownloader
    }
    
    @MainActor func downloadPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<Void, Error> {
        
        return latestToolDownloader
            .downloadLatestToolsPublisher(inLanguages: [appLanguage])
            .eraseToAnyPublisher()
    }
}
