//
//  LanguageDownloadStatusDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum LanguageDownloadStatusDomainModel: Equatable {
    
    case notDownloaded
    case downloading(progress: Double)
    case downloaded
    
    init(downloadedLanguage: DownloadedLanguageDataModel?) {
        
        guard let downloadedLanguage = downloadedLanguage else {
            
            self = .notDownloaded
            return
        }
        
        if downloadedLanguage.isDownloaded {
            
            self = .downloaded
            
        } else {
            
            self = .downloading(progress: downloadedLanguage.downloadProgress)
        }
    }
}
