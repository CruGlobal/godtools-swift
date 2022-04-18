//
//  ReloadAllToolsFromCacheUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ReloadAllToolsFromCacheUseCase {
    
    private let dataDownloader: InitialDataDownloader
    
    init(dataDownloader: InitialDataDownloader) {
        self.dataDownloader = dataDownloader
    }
    
    func reload() -> [ResourceModel] {
        let sortedResources: [ResourceModel] = dataDownloader.resourcesCache.getSortedResources()
        let resources: [ResourceModel] = sortedResources.filter({
            let resourceType: ResourceType = $0.resourceTypeEnum
            return (resourceType == .tract || resourceType == .article || resourceType == .chooseYourOwnAdventure) && !$0.isHidden
        })
        
        return resources
    }
}
