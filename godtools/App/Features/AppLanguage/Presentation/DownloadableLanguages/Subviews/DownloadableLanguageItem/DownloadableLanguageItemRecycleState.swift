//
//  DownloadableLanguageItemRecycleState.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class DownloadableLanguageItemRecycleState: ObservableObject {

    // NOTE: This object is used to maintain the view state when the view is recycled so these objects will remain in memory.
    //       Need to be careful that we don't add high memory cost references here such as images. ~Levi
    
    @Published var downloadState: DownloadableLanguageDownloadState
    @Published var downloadError: Error?
    @Published var isMarkedForRemoval: Bool = false
    
    init(downloadableLanguage: DownloadableLanguageListItemDomainModel) {
        
        switch downloadableLanguage.downloadStatus {
        case .notDownloaded:
            downloadState = .notDownloaded
        case .downloaded( _):
            downloadState = .downloaded
        }
    }
}
