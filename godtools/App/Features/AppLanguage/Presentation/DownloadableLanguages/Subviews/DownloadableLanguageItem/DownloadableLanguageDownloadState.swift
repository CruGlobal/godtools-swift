//
//  DownloadableLanguageDownloadState.swift
//  godtools
//
//  Created by Levi Eggert on 2/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

enum DownloadableLanguageDownloadState {
    case downloaded
    case downloading(progress: Double)
    case notDownloaded
    
    var isDownloading: Bool {
        switch self {
        case .downloading( _):
            return true
        default:
            return false
        }
    }
}

extension DownloadableLanguageDownloadState: Equatable {
    
}
