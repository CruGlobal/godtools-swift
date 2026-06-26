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
    case failed(errorReason: String)
    
    var isDownloading: Bool {
        switch self {
        case .downloading( _):
            return true
        default:
            return false
        }
    }
    
    var failed: Bool {
        switch self {
        case .failed( _):
            return true
        default:
            return false
        }
    }
    
    var errorReason: String? {
        switch self {
        case .failed(let errorReason):
            return errorReason
        default:
            return nil
        }
    }
}

extension DownloadableLanguageDownloadState: Equatable {

}
